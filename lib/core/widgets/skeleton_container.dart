import 'package:flutter/material.dart';

class SkeletonContainer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonContainer({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  // Convenience constructors for common use cases
  const SkeletonContainer.square({
    Key? key,
    double size = 50,
    double borderRadius = 8,
  }) : this(
          key: key,
          width: size,
          height: size,
          borderRadius: borderRadius,
        );

  const SkeletonContainer.circular({
    Key? key,
    double size = 50,
  }) : this(
          key: key,
          width: size,
          height: size,
          borderRadius: size / 2,
        );

  const SkeletonContainer.text({
    Key? key,
    double width = double.infinity,
    double height = 16,
  }) : this(
          key: key,
          width: width,
          height: height,
          borderRadius: height / 2,
        );

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.1, 0.5, 0.9],
              colors: [
                isDark
                    ? Colors.grey[800]!.withOpacity(0.9)
                    : Colors.grey[300]!.withOpacity(0.9),
                isDark
                    ? Colors.grey[700]!.withOpacity(0.8)
                    : Colors.grey[200]!.withOpacity(0.8),
                isDark
                    ? Colors.grey[800]!.withOpacity(0.9)
                    : Colors.grey[300]!.withOpacity(0.9),
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}
