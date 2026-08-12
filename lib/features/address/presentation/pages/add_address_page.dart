import 'package:electro/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/address/data/models/address_model.dart';
import 'package:electro/features/address/presentation/bloc/address_bloc.dart';
import 'package:electro/features/address/presentation/bloc/address_event.dart';
import 'package:electro/features/address/presentation/bloc/address_state.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddAddressPage extends StatefulWidget {
  final AddressModel? address;
  const AddAddressPage({super.key, this.address});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _address1Controller;
  late final TextEditingController _address2Controller;
  late final TextEditingController _cityController;
  late final TextEditingController _pincodeController;

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoadingLocation = false;

  late String _selectedLabel;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.address?.fullName);
    _phoneController = TextEditingController(text: widget.address?.phoneNumber);
    _address1Controller = TextEditingController(
      text: widget.address?.addressLine1,
    );
    _address2Controller = TextEditingController(
      text: widget.address?.addressLine2,
    );
    _cityController = TextEditingController(text: widget.address?.city);
    _pincodeController = TextEditingController(text: widget.address?.pincode);

    _selectedLabel = widget.address?.addressType.toLowerCase() == 'office'
        ? 'Office'
        : widget.address?.addressType.toLowerCase() == 'other'
        ? 'Other'
        : 'Home';
    _isDefault = widget.address?.isDefault ?? false;

    if (widget.address == null) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        CustomToast.showError(context, 'Location services are disabled.');
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          CustomToast.showError(context, 'Location permissions are denied');
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        CustomToast.showError(
          context,
          'Location permissions are permanently denied.',
        );
      setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = currentLatLng;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 15),
        );
      }

      await _getAddressFromLatLng(currentLatLng);
    } catch (e) {
      if (mounted) CustomToast.showError(context, 'Error getting location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _address1Controller.text =
              '${place.street ?? ''}, ${place.subLocality ?? ''}'.replaceAll(
                RegExp(r'^, |, $'),
                '',
              );
          _address2Controller.text = place.locality ?? '';
          _cityController.text = place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = AddressModel(
        id: widget.address?.id ?? 0,
        addressType: _selectedLabel.toLowerCase(),
        fullName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        addressLine1: _address1Controller.text,
        addressLine2: _address2Controller.text.isEmpty
            ? null
            : _address2Controller.text,
        city: _cityController.text,
        pincode: _pincodeController.text,
        isDefault: _isDefault,
      );

      if (widget.address != null) {
        context.read<AddressBloc>().add(
          EditAddress(widget.address!.id, address.toJson()),
        );
      } else {
        context.read<AddressBloc>().add(AddAddress(address));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressActionSuccess) {
          CustomToast.showSuccess(context, state.message);
          Navigator.pop(context);
        } else if (state is AddressError) {
          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildAppBar(context),
                  const SizedBox(height: 24),
                  Text(
                    widget.address != null ? 'Edit Address' : 'Add New Address',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Lufga',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ensure your delivery details are correct',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildMapContainer(),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildLabelSelector(),
                        const SizedBox(height: 32),
                        _buildTextField(
                          'Full Name',
                          'Enter your full name',
                          Icons.person_outline_rounded,
                          controller: _fullNameController,
                          validator: (val) =>
                              val!.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          'Phone Number',
                          'Enter your phone number',
                          Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (val) => val!.length < 10
                              ? 'Enter valid phone number'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          'Address Line 1',
                          'House No, Building, Street',
                          Icons.location_on_outlined,
                          controller: _address1Controller,
                          validator: (val) =>
                              val!.isEmpty ? 'Address is required' : null,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          'Address Line 2',
                          'Area, Landmark (Optional)',
                          Icons.map_outlined,
                          controller: _address2Controller,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                'City',
                                'City',
                                Icons.location_city_outlined,
                                controller: _cityController,
                                validator: (val) =>
                                    val!.isEmpty ? 'City is required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                'Pincode',
                                '123456',
                                Icons.pin_drop_outlined,
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                validator: (val) =>
                                    val!.length != 6 ? 'Invalid pincode' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildDefaultSwitch(),
                        const SizedBox(height: 32),
                        BlocBuilder<AddressBloc, AddressState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: widget.address != null
                                  ? 'Update Address'
                                  : 'Save Address',
                              onPressed: state is AddressLoading
                                  ? null
                                  : _saveAddress,
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
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
      ],
    );
  }

  Widget _buildMapContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pin Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Lufga',
              ),
            ),
            if (_isLoadingLocation)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1D7A91),
                ),
              )
            else
              GestureDetector(
                onTap: _getCurrentLocation,
                child: const Text(
                  'Use Current Location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D7A91),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          clipBehavior: Clip.hardEdge,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(25.2048, 55.2708),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_selectedLocation != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                );
              }
            },
            onTap: (LatLng location) {
              setState(() => _selectedLocation = location);
              _getAddressFromLatLng(location);
            },
            markers: _selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation!,
                    ),
                  },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),
      ],
    );
  }

  Widget _buildLabelSelector() {
    return Row(
      children: [
        _buildLabelChip('Home', Icons.home_rounded),
        const SizedBox(width: 12),
        _buildLabelChip('Office', Icons.work_rounded),
        const SizedBox(width: 12),
        _buildLabelChip('Other', Icons.location_on_rounded),
      ],
    );
  }

  Widget _buildLabelChip(String label, IconData icon) {
    final isSelected = _selectedLabel == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLabel = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1D7A91)
                : const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1D7A91)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
            fontFamily: 'Lufga',
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.2),
              size: 18,
            ),
            filled: true,
            fillColor: const Color(0xFF151515),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF1D7A91)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Set as default address',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Switch.adaptive(
            value: _isDefault,
            activeColor: const Color(0xFF1D7A91),
            onChanged: (val) => setState(() => _isDefault = val),
          ),
        ],
      ),
    );
  }
}
