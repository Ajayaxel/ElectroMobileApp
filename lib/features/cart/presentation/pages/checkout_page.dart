import 'package:electro/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:electro/features/cart/models/cart_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/address/presentation/bloc/address_bloc.dart';
import 'package:electro/features/address/presentation/bloc/address_state.dart';
import 'package:electro/features/address/presentation/bloc/address_event.dart';
import 'package:electro/features/address/presentation/pages/shipping_address_page.dart';
import 'package:electro/features/cart/data/repositories/order_repository.dart';
import 'package:electro/features/address/data/repositories/address_repository.dart';
import 'package:electro/features/cart/bloc/cart_bloc.dart';
import 'package:electro/features/cart/bloc/cart_event_state.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/features/address/data/models/address_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:electro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:electro/features/auth/presentation/bloc/auth_state.dart';
import 'package:electro/features/orders/presentation/bloc/order_bloc.dart';
import 'package:electro/features/orders/presentation/bloc/order_event.dart';

class CheckoutPage extends StatefulWidget {
  final CartModel cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'Cash on Delivery';
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  final OrderRepository _orderRepository = OrderRepository();
  bool _isFetchingLocation = false;
  AddressModel? _tempLocationAddress;

  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(FetchAddresses());
    _tryFetchCurrentLocation();
  }

  Future<void> _tryFetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        final authState = context.read<AuthBloc>().state;
        String userName = 'User';
        String userPhone = '0000000000';
        if (authState is AuthSuccess) {
          userName = authState.user.name;
          userPhone = authState.user.phone;
        }

        if (mounted) {
          setState(() {
            _tempLocationAddress = AddressModel(
              id: 0,
              addressType: 'home',
              fullName: userName,
              phoneNumber: userPhone.isNotEmpty ? userPhone : '0000000000',
              addressLine1:
                  '${place.street ?? ''} ${place.subLocality ?? ''}'
                      .trim()
                      .isEmpty
                  ? 'Current Location'
                  : '${place.street ?? ''} ${place.subLocality ?? ''}'.trim(),
              addressLine2: place.locality,
              city: place.administrativeArea ?? 'Unknown City',
              pincode: place.postalCode ?? '000000',
              isDefault: true,
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Lufga',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Address Section
                    _buildSectionTitle('Shipping Address'),
                    const SizedBox(height: 16),
                    _buildAddressCard(),
                    const SizedBox(height: 32),

                    // Payment Method Section
                    _buildSectionTitle('Payment Method'),
                    const SizedBox(height: 16),
                    _buildPaymentMethodOption('Cash on Delivery', Icons.money),
                    const SizedBox(height: 12),
                    _buildPaymentMethodOption(
                      'Credit / Debit Card',
                      Icons.credit_card,
                    ),
                    const SizedBox(height: 32),

                    // Order Summary Section
                    _buildSectionTitle('Order Summary'),
                    const SizedBox(height: 16),
                    _buildProductList(),
                    const SizedBox(height: 32),

                    // Pricing Breakdown
                    _buildPricingBreakdown(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildPlaceOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        fontFamily: 'Lufga',
      ),
    );
  }

  Widget _buildAddressCard() {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        if (state is AddressLoading && state is! AddressLoaded) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1D7A91)),
          );
        }

        List<AddressModel> addresses = [];
        if (state is AddressLoaded) {
          addresses = state.addresses;
        }

        if (addresses.isEmpty) {
          if (_isFetchingLocation) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFF1D7A91),
                    strokeWidth: 2,
                  ),
                ),
              ),
            );
          }
        }

        final address =
            _selectedAddress ??
            (addresses.isNotEmpty
                ? addresses.firstWhere(
                    (a) => a.isDefault,
                    orElse: () => addresses.first,
                  )
                : _tempLocationAddress);

        if (address == null) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'No Address Selected',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ShippingAddressPage(isSelectionMode: true),
                      ),
                    );
                    if (selected != null && selected is AddressModel) {
                      setState(() {
                        _selectedAddress = selected;
                      });
                    }
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Color(0xFF1D7A91),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D7A91).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          address.addressType.toLowerCase() == 'home'
                              ? Icons.home_filled
                              : address.addressType.toLowerCase() == 'office'
                              ? Icons.work_rounded
                              : Icons.location_on_rounded,
                          size: 20,
                          color: const Color(0xFF1D7A91),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        address.addressType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      final selected = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ShippingAddressPage(isSelectionMode: true),
                        ),
                      );
                      if (selected != null && selected is AddressModel) {
                        setState(() {
                          _selectedAddress = selected;
                        });
                      }
                    },
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        color: Color(0xFF1D7A91),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                address.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${address.addressLine1}${address.addressLine2 != null ? ', ${address.addressLine2}' : ''}\n${address.city}, ${address.pincode}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '+91 ${address.phoneNumber}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodOption(String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = title),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D7A91) : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1D7A91) : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF1D7A91)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cart.items.length,
      itemBuilder: (context, index) {
        final item = widget.cart.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppNetworkImage(
                  url: item.product.image,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'AED ${item.price.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPricingBreakdown() {
    final double deliveryFee = 50.0;
    final double totalAmount = widget.cart.totalPrice + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildPriceRow('Subtotal', 'AED ${widget.cart.totalPrice.toInt()}'),
          const SizedBox(height: 16),
          _buildPriceRow('Delivery Fee', 'AED ${deliveryFee.toInt()}'),
          const SizedBox(height: 20),
          Divider(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lufga',
                ),
              ),
              Text(
                'AED ${totalAmount.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1D7A91),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 15,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: _isLoading
              ? null
              : () async {
                  if (_selectedAddress == null) {
                    final addresses =
                        context.read<AddressBloc>().state is AddressLoaded
                        ? (context.read<AddressBloc>().state as AddressLoaded)
                              .addresses
                        : <AddressModel>[];

                    if (addresses.isEmpty) {
                      if (_tempLocationAddress != null) {
                        _selectedAddress = _tempLocationAddress;
                      } else {
                        CustomToast.showError(
                          context,
                          'Please add a shipping address',
                        );
                        return;
                      }
                    } else {
                      _selectedAddress = addresses.firstWhere(
                        (a) => a.isDefault,
                        orElse: () => addresses.first,
                      );
                    }
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    if (_selectedAddress!.id == 0) {
                      final createdAddress = await AddressRepository()
                          .createAddress(_selectedAddress!);
                      _selectedAddress = createdAddress;
                      if (mounted) {
                        context.read<AddressBloc>().add(FetchAddresses());
                      }
                    }

                    bool success = await _orderRepository.placeOrder(
                      addressId: _selectedAddress!.id,
                      paymentMethod: _selectedPaymentMethod,
                      deliveryFee: 50.0,
                    );

                    if (success) {
                      context.read<CartBloc>().add(FetchCart());
                      context.read<OrderBloc>().add(FetchOrders());

                      if (mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            backgroundColor: const Color(0xFF151515),
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 80,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Order Successful!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Lufga',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your order has been placed successfully. Thank you for shopping with us!',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white.withOpacity(0.5),
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.popUntil(
                                        context,
                                        (route) => route.isFirst,
                                      );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1D7A91),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Back to Home',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    CustomToast.showError(context, e.toString());
                  } finally {
                    if (mounted)
                      setState(() {
                        _isLoading = false;
                      });
                  }
                },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: _isLoading ? Colors.grey[800] : const Color(0xFF1D7A91),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Place Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
