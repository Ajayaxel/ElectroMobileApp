import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banners Shimmer
            const ShimmerPlaceholder(height: 180, width: double.infinity),
            const SizedBox(height: 20),

            // Brands Section Shimmer
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerPlaceholder(height: 24, width: 80),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, __) => const ShimmerPlaceholder(
                      height: 52,
                      width: 120,
                      borderRadius: 30,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recently Added Header Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerPlaceholder(height: 24, width: 150),
                const ShimmerPlaceholder(height: 16, width: 50),
              ],
            ),
            const SizedBox(height: 16),

            // Recently Added Horizontal List Shimmer
            SizedBox(
              height: 245,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, __) => const ShimmerPlaceholder(
                  height: 245,
                  width: 170,
                  borderRadius: 15,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Popular Batteries Header Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerPlaceholder(height: 24, width: 140),
                const ShimmerPlaceholder(height: 16, width: 50),
              ],
            ),
            const SizedBox(height: 16),

            // Popular Batteries Grid Shimmer
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (_, __) => const ShimmerPlaceholder(
                height: 245,
                width: 170,
                borderRadius: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
