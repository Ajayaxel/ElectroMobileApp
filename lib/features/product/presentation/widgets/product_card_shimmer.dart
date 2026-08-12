import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: ShimmerPlaceholder(
                  width: 60,
                  height: 60,
                  borderRadius: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(
                  width: 40,
                  height: 10,
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                const ShimmerPlaceholder(
                  width: 100,
                  height: 14,
                  borderRadius: 4,
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerPlaceholder(
                      width: 60,
                      height: 18,
                      borderRadius: 4,
                    ),
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
