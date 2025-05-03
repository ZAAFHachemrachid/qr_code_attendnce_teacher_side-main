-- Enable required extensions if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Start transaction
BEGIN;

------------------------------------------
-- Real-time Session Status Tracking Tables
------------------------------------------

-- Track session status changes
CREATE TABLE session_status_changes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES live_sessions(id),
    old_status TEXT NOT NULL,
    new_status TEXT NOT NULL,
    change_reason TEXT,
    changed_by UUID REFERENCES profiles(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_session_status_changes ON session_status_changes(session_id, changed_at);

-- WebSocket channel configuration
CREATE TABLE websocket_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES live_sessions(id),
    channel_name TEXT NOT NULL,
    config JSONB NOT NULL DEFAULT '{}',
    active_connections INT DEFAULT 0,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT now(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(session_id, channel_name)
);

CREATE INDEX idx_websocket_channels_session ON websocket_channels(session_id);
CREATE INDEX idx_websocket_channels_activity ON websocket_channels(last_activity);

-- Attendance change tracking
CREATE TABLE attendance_status_changes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attendance_id UUID REFERENCES attendance_records(id),
    old_status BOOLEAN NOT NULL,
    new_status BOOLEAN NOT NULL,
    change_reason TEXT,
    changed_by UUID REFERENCES profiles(id),
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_attendance_status_changes ON attendance_status_changes(attendance_id, changed_at);

-- Real-time analytics
CREATE TABLE session_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES live_sessions(id),
    total_students INT NOT NULL,
    present_count INT NOT NULL,
    connection_count INT NOT NULL,
    status_distribution JSONB NOT NULL DEFAULT '{}',
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE INDEX idx_session_analytics ON session_analytics(session_id, recorded_at);

------------------------------------------
-- Functions and Triggers
------------------------------------------

-- Function to update session analytics
CREATE OR REPLACE FUNCTION update_session_analytics()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO session_analytics (
        session_id,
        total_students,
        present_count,
        connection_count,
        status_distribution
    )
    SELECT
        NEW.session_id,
        COUNT(DISTINCT ar.student_id),
        COUNT(DISTINCT CASE WHEN ar.status THEN ar.student_id END),
        (SELECT active_connections FROM websocket_channels WHERE session_id = NEW.session_id),
        jsonb_build_object(
            'present', SUM(CASE WHEN ar.status THEN 1 ELSE 0 END),
            'absent', SUM(CASE WHEN NOT ar.status THEN 1 ELSE 0 END)
        )
    FROM attendance_records ar
    WHERE ar.session_id = NEW.session_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create analytics update trigger
CREATE TRIGGER attendance_analytics_trigger
AFTER INSERT OR UPDATE ON attendance_records
FOR EACH ROW
EXECUTE FUNCTION update_session_analytics();

------------------------------------------
-- Security Policies
------------------------------------------

-- Enable RLS on new tables
ALTER TABLE session_status_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE websocket_channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_status_changes ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_analytics ENABLE ROW LEVEL SECURITY;

-- Session status change policies
CREATE POLICY "Teachers can manage session status"
ON session_status_changes
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM live_sessions ls
        JOIN courses c ON ls.course_id = c.id
        WHERE ls.id = session_id
        AND c.teacher_id = auth.uid()
    )
);

-- WebSocket channel policies
CREATE POLICY "Users can view relevant channels"
ON websocket_channels
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM live_sessions ls
        WHERE ls.id = session_id
        AND (
            -- Teachers who own the session
            EXISTS (
                SELECT 1 FROM courses c
                WHERE c.id = ls.course_id
                AND c.teacher_id = auth.uid()
            )
            OR
            -- Students in the session's groups
            auth.uid() IN (
                SELECT s.id FROM student_profiles s
                WHERE s.group_id = ANY(ls.group_ids)
            )
        )
    )
);

-- Attendance change policies
CREATE POLICY "Teachers can view attendance changes"
ON attendance_status_changes
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM attendance_records ar
        JOIN live_sessions ls ON ar.session_id = ls.id
        JOIN courses c ON ls.course_id = c.id
        WHERE ar.id = attendance_id
        AND c.teacher_id = auth.uid()
    )
);

-- Analytics access policies
CREATE POLICY "Teachers can view session analytics"
ON session_analytics
FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM live_sessions ls
        JOIN courses c ON ls.course_id = c.id
        WHERE ls.id = session_id
        AND c.teacher_id = auth.uid()
    )
);

------------------------------------------
-- Realtime Configuration
------------------------------------------

-- Enable realtime for new tables
ALTER PUBLICATION live_attendance_pub ADD TABLE 
    session_status_changes,
    websocket_channels,
    attendance_status_changes,
    session_analytics;

-- Commit transaction
COMMIT;