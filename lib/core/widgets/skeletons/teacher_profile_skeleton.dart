import 'package:flutter/material.dart';
import '../skeleton_container.dart';

class TeacherProfileSkeleton extends StatelessWidget {
  const TeacherProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                SkeletonContainer.circular(size: 60),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonContainer.text(width: 150, height: 24),
                      SizedBox(height: 8),
                      SkeletonContainer.text(width: 100),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SkeletonContainer.text(width: 120, height: 20),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, __) => const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkeletonContainer.text(width: 100),
                  SkeletonContainer.text(width: 150),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SkeletonContainer.text(width: 140, height: 20),
            const SizedBox(height: 16),
            const SkeletonContainer(height: 48),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkeletonContainer.text(width: 80),
                SizedBox(width: 8),
                SkeletonContainer.text(width: 120),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
