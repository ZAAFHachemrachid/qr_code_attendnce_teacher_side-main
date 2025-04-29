import 'package:flutter/material.dart';
import '../skeleton_container.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.8),
                ],
              ),
            ),
            child: const Column(
              children: [
                SizedBox(height: 32),
                SkeletonContainer.circular(size: 100),
                SizedBox(height: 16),
                SkeletonContainer.text(width: 200),
                SizedBox(height: 8),
                SkeletonContainer.text(width: 150),
                SizedBox(height: 32),
              ],
            ),
          ),

          // Info Cards Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoCard(context, 'Personal Information'),
                const SizedBox(height: 16),
                _buildInfoCard(context, 'Current Semester'),
                const SizedBox(height: 16),
                _buildInfoCard(context, 'Contact Information'),
                const SizedBox(height: 24),
                const SkeletonContainer(width: 120, height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonContainer.square(size: 40),
                SizedBox(width: 12),
                SkeletonContainer.text(
                  width: 150,
                  height: 24,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonContainer.text(width: 100),
                      SkeletonContainer.text(width: 120),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
