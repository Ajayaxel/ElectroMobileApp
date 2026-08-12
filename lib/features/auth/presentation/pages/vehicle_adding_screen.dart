import 'package:electro/core/widgets/app_network_image.dart';
import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/features/main/presentation/pages/main_screen.dart';
import 'package:electro/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicle_model_selection_screen.dart';

class VehicleAddingScreen extends StatefulWidget {
  final NestedVehicleType? selectedType;
  const VehicleAddingScreen({super.key, this.selectedType});

  @override
  State<VehicleAddingScreen> createState() => _VehicleAddingScreenState();
}

class _VehicleAddingScreenState extends State<VehicleAddingScreen> {
  final VehicleRepository _repository = VehicleRepository();
  final TextEditingController _searchController = TextEditingController();
  List<NestedBrand> _brands = [];
  List<NestedBrand> _filteredBrands = [];
  bool _isLoading = true;
  int? _selectedBrandId;
  String? _selectedBrandName;

  @override
  void initState() {
    super.initState();
    if (widget.selectedType != null) {
        _brands = widget.selectedType!.brands;
        _filteredBrands = _brands;
        _isLoading = false;
        if (_brands.isNotEmpty) {
            _selectedBrandId = _brands[0].brandId;
            _selectedBrandName = _brands[0].brandName;
        }
    } else {
        _loadBrands();
    }
  }

  Future<void> _loadBrands() async {
    try {
      // If no type selected, we probably shouldn't be here, but let's fallback to all brands
      final brandsRes = await _repository.getBrands();
      // Need to convert to NestedBrand format if needed, but let's assume we always have selectedType now
      setState(() {
        // ... handled by repository usually, but since we redesigned the flow, 
        // we'll mostly come from TypeSelectionScreen
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterBrands(String query) {
    setState(() {
      _filteredBrands = _brands
          .where(
            (brand) => brand.brandName.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Power Your Electric Drive",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We'll show batteries that fit your car perfectly",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Search Bar
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.darkSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.5),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterBrands,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search your vehicle (e.g. BMW ix3 )",
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Skip Button (optional, but keep it somewhere if needed)
              /*
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                  ),
                  child: const Text("Skip", style: TextStyle(color: Colors.grey)),
                ),
              ),
              */

              // Brands List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _filteredBrands.isEmpty
                    ? const Center(
                        child: Text(
                          "No brands found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListWheelScrollView.useDelegate(
                        itemExtent: 130,
                        perspective: 0.005,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedBrandId = _filteredBrands[index].brandId;
                            _selectedBrandName = _filteredBrands[index].brandName;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _filteredBrands.length,
                          builder: (context, index) {
                            final brand = _filteredBrands[index];
                            final isSelected = _selectedBrandId == brand.brandId;

                            return AnimatedScale(
                              scale: isSelected ? 1.05 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedOpacity(
                                opacity: isSelected ? 1.0 : 0.5,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: isSelected
                                        ? AppColors.darkSoft
                                        : Colors.transparent,
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.primary,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Brand Logo
                                      Container(
                                        width: 80,
                                        height: 80,
                                        padding: const EdgeInsets.all(8),
                                        child: AppNetworkImage(
                                          url: brand.image,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // Brand Info
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            brand.brandName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${brand.models.length} Models Available",
                                            style: TextStyle(
                                              color: Colors.grey.withOpacity(
                                                0.6,
                                              ),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: CustomButton(
                  text: "Continue",
                  onPressed: _selectedBrandId == null
                      ? null
                      : () {
                          final selectedBrand = _filteredBrands.firstWhere((b) => b.brandId == _selectedBrandId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehicleModelSelectionScreen(
                                brandId: _selectedBrandId!,
                                brandName: _selectedBrandName!,
                                vehicleType: widget.selectedType?.id ?? 'car',
                                initialModels: selectedBrand.models,
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
