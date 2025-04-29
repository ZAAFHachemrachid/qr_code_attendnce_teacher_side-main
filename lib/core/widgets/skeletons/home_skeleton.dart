import 'package:flutter/material.dart';
import '../skeleton_container.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildTodayOverviewCard(context),
            const SizedBox(height: 24),
            _buildActionGrid(context),
            const SizedBox(height: 24),
            _buildAttendanceCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonContainer.text(width: 150, height: 24),
        SizedBox(height: 8),
        SkeletonContainer.text(width: 200, height: 32),
        SizedBox(height: 8),
        SkeletonContainer.text(width: 180),
      ],
    );
  }

  Widget _buildTodayOverviewCard(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonContainer.square(size: 40),
                SizedBox(width: 12),
                SkeletonContainer.text(width: 150, height: 24),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonContainer.text(width: 120),
                SkeletonContainer.text(width: 80),
              ],
            ),
            SizedBox(height: 12),
            SkeletonContainer(height: 8),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonContainer.text(width: 100),
                SkeletonContainer.text(width: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: List.generate(
        4,
        (index) => _buildActionCard(context),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[300]!.withOpacity(0.5),
              Colors.grey[200]!.withOpacity(0.3),
            ],
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SkeletonContainer.square(size: 40),
            SizedBox(height: 12),
            SkeletonContainer.text(width: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonContainer.square(size: 40),
                SizedBox(width: 8),
                SkeletonContainer.text(width: 180, height: 24),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => const Column(
                  children: [
                    SkeletonContainer.text(width: 40, height: 24),
                    SizedBox(height: 4),
                    SkeletonContainer.text(width: 60),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SkeletonContainer(height: 8),
            const SizedBox(height: 12),
            const SkeletonContainer.text(width: 150),
          ],
        ),
      ),
    );
  }
}
