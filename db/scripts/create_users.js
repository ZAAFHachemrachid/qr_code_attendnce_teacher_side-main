const fetch = require('node-fetch');
const fs = require('fs/promises');

// Configuration
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_SERVICE_ROLE_KEY = 'YOUR_SERVICE_ROLE_KEY';
const DEFAULT_PASSWORD = 'DefaultPass123!';
const RATE_LIMIT_DELAY = 100; // ms between requests
const OUTPUT_FILE = 'created_users.json';

// Departments for teachers
const DEPARTMENTS = ['Computer Science', 'Mathematics', 'Physics', 'Chemistry'];

// Helper function for rate limiting
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Helper function to create a single user
async function createUser(email, metadata) {
    try {
        const response = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'apikey': SUPABASE_SERVICE_ROLE_KEY,
                'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
            },
            body: JSON.stringify({
                email,
                password: DEFAULT_PASSWORD,
                email_confirm: true,
                user_metadata: metadata
            })
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(`Failed to create user ${email}: ${JSON.stringify(error)}`);
        }

        const data = await response.json();
        console.log(`✅ Created user: ${email}`);
        return data;
    } catch (error) {
        console.error(`❌ Error creating user ${email}:`, error.message);
        return null;
    }
}

// Main function to create all users
async function createAllUsers() {
    const createdUsers = {
        teachers: [],
        students: []
    };

    // Create teachers
    console.log('\n📚 Creating teachers...');
    for (let i = 1; i <= 4; i++) {
        const email = `teacher${i}@example.com`;
        const metadata = {
            role: 'teacher',
            department: DEPARTMENTS[i - 1],
            full_name: `Teacher ${i}`
        };

        const user = await createUser(email, metadata);
        if (user) {
            createdUsers.teachers.push({
                id: user.id,
                email,
                metadata
            });
        }
        await sleep(RATE_LIMIT_DELAY);
    }

    // Create students
    console.log('\n👥 Creating students...');
    for (let i = 1; i <= 60; i++) {
        const email = `student${i}@example.com`;
        const metadata = {
            role: 'student',
            full_name: `Student ${i}`,
            student_id: `STU${String(i).padStart(3, '0')}`
        };

        const user = await createUser(email, metadata);
        if (user) {
            createdUsers.students.push({
                id: user.id,
                email,
                metadata
            });
        }
        await sleep(RATE_LIMIT_DELAY);
    }

    // Save created users to file
    try {
        await fs.writeFile(OUTPUT_FILE, JSON.stringify(createdUsers, null, 2));
        console.log(`\n💾 Saved user data to ${OUTPUT_FILE}`);
    } catch (error) {
        console.error('Error saving user data:', error);
    }

    // Print summary
    console.log('\n📊 Summary:');
    console.log(`Teachers created: ${createdUsers.teachers.length}/4`);
    console.log(`Students created: ${createdUsers.students.length}/60`);
}

// Check configuration
function validateConfig() {
    if (SUPABASE_URL === 'YOUR_SUPABASE_URL' || SUPABASE_SERVICE_ROLE_KEY === 'YOUR_SERVICE_ROLE_KEY') {
        console.error('❌ Error: Please configure SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY');
        process.exit(1);
    }
}

// Run the script
console.log('🚀 Starting user creation process...');
validateConfig();
createAllUsers()
    .then(() => console.log('\n✨ Process completed'))
    .catch(error => console.error('\n❌ Process failed:', error));