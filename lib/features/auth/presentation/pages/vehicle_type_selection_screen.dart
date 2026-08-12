import 'package:electro/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/vehicle_repository.dart';
import 'vehicle_adding_screen.dart';

class VehicleTypeSelectionScreen extends StatefulWidget {
  const VehicleTypeSelectionScreen({super.key});

  @override
  State<VehicleTypeSelectionScreen> createState() => _VehicleTypeSelectionScreenState();
}

class _VehicleTypeSelectionScreenState extends State<VehicleTypeSelectionScreen> {
  final VehicleRepository _repository = VehicleRepository();
  List<NestedVehicleType> _allData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _repository.getNestedVehicleData();
      if (!mounted) return;
      setState(() {
        _allData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vehicle data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              "Select Vehicle Type",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "What are you driving today?",
              style: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _allData.isEmpty
                      ? const Center(child: Text("No data available", style: TextStyle(color: Colors.white)))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: _allData.length,
                          itemBuilder: (context, index) {
                            final type = _allData[index];
                            return _buildTypeCard(type);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(NestedVehicleType type) {
    IconData icon;
    switch (type.id.toLowerCase()) {
      case 'car':
        icon = Icons.directions_car_rounded;
        break;
      case 'bike':
      case 'motorcycle':
        icon = Icons.directions_bike_rounded;
        break;
      case 'scooter':
        icon = Icons.moped_rounded;
        break;
      default:
        icon = Icons.electric_car_rounded;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleAddingScreen(
              selectedType: type,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSoft,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              type.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${type.brands.length} Brands",
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
