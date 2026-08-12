import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const ShimmerPlaceholder(width: 110, height: 110, borderRadius: 55),
          const SizedBox(height: 15),
          const ShimmerPlaceholder(width: 150, height: 24, borderRadius: 4),
          const SizedBox(height: 10),
          const ShimmerPlaceholder(width: 200, height: 16, borderRadius: 4),
          const SizedBox(height: 40),
          _buildShimmerSection(),
          _buildShimmerSection(),
        ],
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10),
          child: ShimmerPlaceholder(width: 100, height: 14, borderRadius: 4),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const ShimmerPlaceholder(
                      width: 44,
                      height: 44,
                      borderRadius: 14,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerPlaceholder(
                            width: 100,
                            height: 14,
                            borderRadius: 4,
                          ),
                          const SizedBox(height: 8),
                          const ShimmerPlaceholder(
                            width: 150,
                            height: 12,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
