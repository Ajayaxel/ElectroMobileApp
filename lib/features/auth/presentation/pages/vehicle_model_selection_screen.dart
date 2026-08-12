import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/features/main/presentation/pages/main_screen.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'package:electro/widgets/custom_button.dart';

class VehicleModelSelectionScreen extends StatefulWidget {
  final int brandId;
  final String brandName;
  final String? vehicleType;
  final List<VehicleModelItem>? initialModels;

  const VehicleModelSelectionScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    this.vehicleType,
    this.initialModels,
  });

  @override
  State<VehicleModelSelectionScreen> createState() =>
      _VehicleModelSelectionScreenState();
}

class _VehicleModelSelectionScreenState
    extends State<VehicleModelSelectionScreen> {
  final VehicleRepository _repository = VehicleRepository();
  final TextEditingController _searchController = TextEditingController();
  final FixedExtentScrollController _wheelController =
      FixedExtentScrollController();

  String selectedCategory = "";
  List<String> modelCategories = [];
  List<VehicleModelItem> _models = [];
  List<VehicleModelItem> _filteredModels = [];
  bool _isLoadingCategories = true;
  bool _isLoadingModels = false;

  int _selectedModelIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialModels != null && widget.vehicleType != null) {
      _models = widget.initialModels!;
      _filteredModels = _models;
      final categories = _models
          .map((m) => m.category)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      modelCategories = categories;
      if (modelCategories.isNotEmpty) {
        selectedCategory = modelCategories.first;
      } else {
        _filteredModels = _models;
      }
      _isLoadingCategories = false;
      _isLoadingModels = false;
      if (selectedCategory.isNotEmpty) {
        _applyCategoryFilter();
      }
    } else {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    if ((widget.vehicleType ?? '').isEmpty) {
      if (mounted) setState(() => _isLoadingCategories = false);
      return;
    }
    try {
      final categories = await _repository.getModelCategories(
        vehicleType: widget.vehicleType!,
      );
      if (mounted) {
        setState(() {
          modelCategories = categories;
          if (categories.isNotEmpty) {
            selectedCategory = categories[0];
          }
          _isLoadingCategories = false;
        });
        _loadModels();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  void _applyCategoryFilter() {
    final filtered = _models
        .where((model) => model.category.toLowerCase() == selectedCategory.toLowerCase())
        .toList();
    setState(() {
      _filteredModels = filtered;
      _selectedModelIndex = 0;
    });
    if (_filteredModels.isNotEmpty) {
      _wheelController.jumpToItem(0);
    }
  }

  Future<void> _loadModels() async {
    if ((widget.vehicleType ?? '').isEmpty) return;
    setState(() => _isLoadingModels = true);
    try {
      final models = await _repository.getModels(
        widget.brandId,
        widget.vehicleType!,
        category: selectedCategory.isNotEmpty ? selectedCategory : null,
      );
      if (mounted) {
        setState(() {
          _models = models;
          _filteredModels = models;
          _isLoadingModels = false;
          _selectedModelIndex = 0;
        });
        _wheelController.jumpToItem(0);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingModels = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load models: $e')));
      }
    }
  }

  void _filterModels(String query) {
    setState(() {
      _filteredModels = _models
          .where(
            (model) => model.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      _selectedModelIndex = 0;
    });
    if (_filteredModels.isNotEmpty) {
      _wheelController.jumpToItem(0);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _wheelController.dispose();
    super.dispose();
  }

  void _showAddVehicleBottomSheet(
    BuildContext context,
    VehicleModelItem model,
  ) {
    final TextEditingController vehicleNumberController =
        TextEditingController();
    String selectedCountry = 'United Arab Emirates (UAE)';
    String? selectedEmirate;
    String? selectedPlateCode;
    bool isSubmitting = false;
    String? errorMessage;

    final Map<String, List<String>> emirateData = {
      'Abu Dhabi': [for (int i = 1; i <= 20; i++) i.toString(), '50'],
      'Dubai': [
        ...List.generate(26, (i) => String.fromCharCode(65 + i)),
        ...List.generate(
          26,
          (i) => String.fromCharCode(65 + i) + String.fromCharCode(65 + i),
        ),
      ],
      'Sharjah': ['1', '2', '3', '4'],
      'Ajman': List.generate(26, (i) => String.fromCharCode(65 + i)),
      'Fujairah': List.generate(26, (i) => String.fromCharCode(65 + i)),
      'Ras Al Khaimah': List.generate(26, (i) => String.fromCharCode(65 + i)),
      'Umm Al Quwain': List.generate(26, (i) => String.fromCharCode(65 + i)),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "Add Your ${widget.brandName} ${model.name}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                  ],

                  _buildFieldLabel("Country"),
                  _buildDisabledField(selectedCountry, Icons.lock_outline),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Emirates"),
                            _buildDropdown(
                              value: selectedEmirate,
                              hint: "Select",
                              items: emirateData.keys.toList(),
                              onChanged: (val) {
                                setModalState(() {
                                  selectedEmirate = val;
                                  selectedPlateCode = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel("Code"),
                            _buildDropdown(
                              value: selectedPlateCode,
                              hint: "Code",
                              items: selectedEmirate != null
                                  ? (emirateData[selectedEmirate!] ?? [])
                                  : [],
                              onChanged: (val) {
                                setModalState(() => selectedPlateCode = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildFieldLabel("Plate Number"),
                  TextField(
                    controller: vehicleNumberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Enter Digits"),
                  ),

                  const SizedBox(height: 40),
                  CustomButton(
                    text: "Submit",
                    isLoading: isSubmitting,
                    onPressed: () async {
                      if (selectedEmirate == null ||
                          selectedPlateCode == null ||
                          vehicleNumberController.text.isEmpty) {
                        setModalState(
                          () => errorMessage = "Please fill all fields",
                        );
                        return;
                      }
                      setModalState(() => isSubmitting = true);
                      try {
                        final resolvedVehicleType = model.type.isNotEmpty
                            ? model.type
                            : ((widget.vehicleType ?? '').isNotEmpty
                                  ? widget.vehicleType!
                                  : 'car');

                        final result = await _repository.addUserVehicle(
                          userId: 1, // Actual user ID should be used
                          brandId: widget.brandId,
                          modelId: model.id,
                          vehicleType: resolvedVehicleType,
                          country: selectedCountry,
                          emirate: selectedEmirate!,
                          plateCode: selectedPlateCode!,
                          plateNumber: vehicleNumberController.text,
                        );

                        print('UI RESULT: $result');

                        if (result['success'] == true) {
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        } else {
                          setModalState(
                            () => errorMessage =
                                result['message'] ?? 'Failed to add vehicle',
                          );
                        }
                      } catch (e) {
                        setModalState(
                          () => errorMessage = "Error adding vehicle",
                        );
                      } finally {
                        setModalState(() => isSubmitting = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.withOpacity(0.8), fontSize: 14),
      ),
    );
  }

  Widget _buildDisabledField(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Icon(icon, size: 20, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.darkSoft,
          hint: Text(
            hint,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 14,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
      filled: true,
      fillColor: AppColors.backgroundDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
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
                    Text(
                      "Choose Your ${widget.brandName} Model",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Find the perfect battery tailored for your vehicle",
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
                        onChanged: _filterModels,
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
              const SizedBox(height: 20),

              // Category Chips
              _isLoadingCategories
                  ? const SizedBox(height: 50)
                  : SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: modelCategories.length,
                        itemBuilder: (context, index) {
                          final category = modelCategories[index];
                          final isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedCategory = category);
                                if (widget.initialModels != null) {
                                  _applyCategoryFilter();
                                  return;
                                }
                                _loadModels();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    category.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 30),

              // Models Wheel
              Expanded(
                child: _isLoadingModels
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _filteredModels.isEmpty
                    ? const Center(
                        child: Text(
                          "No models found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListWheelScrollView.useDelegate(
                        controller: _wheelController,
                        itemExtent: 80,
                        perspective: 0.005,
                        diameterRatio: 1.8,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          setState(() => _selectedModelIndex = index);
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: _filteredModels.length,
                          builder: (context, index) {
                            final model = _filteredModels[index];
                            final isSelected = _selectedModelIndex == index;

                            // Avoid doubling brand name if it's already present in model name
                            String displayName = model.name;
                            if (!displayName.toLowerCase().startsWith(
                              widget.brandName.toLowerCase(),
                            )) {
                              displayName = "${widget.brandName} $displayName";
                            }

                            return Center(
                              child: AnimatedScale(
                                scale: isSelected ? 1.1 : 0.8,
                                duration: const Duration(milliseconds: 200),
                                child: AnimatedOpacity(
                                  opacity: isSelected ? 1.0 : 0.2,
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    displayName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      fontSize: isSelected ? 30 : 22,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
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
                  onPressed: _filteredModels.isEmpty
                      ? null
                      : () {
                          _showAddVehicleBottomSheet(
                            context,
                            _filteredModels[_selectedModelIndex],
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
