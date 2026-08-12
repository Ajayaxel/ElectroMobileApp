import 'package:electro/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:electro/features/home/data/home_repository.dart';
import 'package:electro/features/home/models/home_models.dart';
import 'package:electro/features/product/presentation/pages/all_products_page.dart';
import 'package:electro/core/widgets/empty_state_widget.dart';

class BrandFilterPage extends StatefulWidget {
  final String brandName;
  final List<ProductModel> allProducts;

  const BrandFilterPage({
    super.key,
    required this.brandName,
    required this.allProducts,
  });

  @override
  State<BrandFilterPage> createState() => _BrandFilterPageState();
}

class _BrandFilterPageState extends State<BrandFilterPage> {
  List<String> _capacities = [];
  bool _isLoadingCapacities = true;
  final HomeRepository _repository = HomeRepository();

  final Set<String> _selectedCapacities = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCapacities();
  }

  Future<void> _loadCapacities() async {
    final caps = await _repository.fetchBrandCapacities(widget.brandName);
    if (mounted) {
      setState(() {
        _capacities = caps;
        _isLoadingCapacities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCapacities = _capacities
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Capacity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Lufga',
                        ),
                      ),
                      if (_selectedCapacities.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _selectedCapacities.clear()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Clear all',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoadingCapacities
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF1D7A91)),
                        )
                      : filteredCapacities.isEmpty
                          ? Center(
                              child: EmptyStateWidget(
                                title: 'No Capacities Found',
                                description: 'We couldn\'t find any battery capacities matching your search for ${widget.brandName}.',
                                icon: Icons.battery_alert_rounded,
                                onActionPressed: () => setState(() => _searchQuery = ''),
                                actionLabel: 'Clear Search',
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: filteredCapacities.length,
                              itemBuilder: (context, index) {
                                final capacity = filteredCapacities[index];
                                final isSelected = _selectedCapacities.contains(capacity);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedCapacities.remove(capacity);
                                      } else {
                                        _selectedCapacities.add(capacity);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFF1D7A91).withOpacity(0.1) : const Color(0xFF151515),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFF1D7A91) : Colors.white.withOpacity(0.05),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        capacity,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),

          // Bottom button
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: CustomButton(
              height: 56,
              text: _selectedCapacities.isEmpty
                  ? 'Show All ${widget.brandName} Products'
                  : 'Show Results (${_selectedCapacities.length})',
              onPressed: () {
                final filtered = widget.allProducts.where((p) {
                  final matchesBrand =
                      p.brand.toLowerCase() == widget.brandName.toLowerCase();
                  if (!matchesBrand) return false;

                  if (_selectedCapacities.isEmpty) return true;
                  return _selectedCapacities.contains(p.capacity);
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllProductsPage(
                      products: filtered,
                      title: '${widget.brandName} Products',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.brandName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lufga',
                ),
              ),
              Text(
                'Filtration Options',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Search capacity...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
