import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/address/data/models/address_model.dart';
import 'package:electro/features/address/presentation/bloc/address_bloc.dart';
import 'package:electro/features/address/presentation/bloc/address_event.dart';
import 'package:electro/features/address/presentation/bloc/address_state.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/widgets/custom_button.dart';
import 'add_address_page.dart';

class ShippingAddressPage extends StatefulWidget {
  final bool isSelectionMode;
  const ShippingAddressPage({super.key, this.isSelectionMode = false});

  @override
  State<ShippingAddressPage> createState() => _ShippingAddressPageState();
}

class _ShippingAddressPageState extends State<ShippingAddressPage> {
  @override
  void initState() {
    super.initState();
    context.read<AddressBloc>().add(FetchAddresses());
  }

  void _deleteAddress(int id) {
    context.read<AddressBloc>().add(DeleteAddress(id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressActionSuccess) {
          CustomToast.showSuccess(context, state.message);
        } else if (state is AddressError) {
          CustomToast.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    if (state is AddressLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF1D7A91)),
                      );
                    }

                    if (state is AddressLoaded) {
                      final addresses = state.addresses;
                      if (addresses.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          return _buildAddressCard(addresses[index]);
                        },
                      );
                    }

                    return _buildEmptyState();
                  },
                ),
              ),
              _buildAddButton(context),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lufga',
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Manage your delivery locations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return GestureDetector(
      onTap: () {
        if (widget.isSelectionMode) {
          Navigator.pop(context, address);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: address.isDefault
                ? const Color(0xFF1D7A91).withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
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
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        address.addressType.toLowerCase() == 'home'
                            ? Icons.home_rounded
                            : address.addressType.toLowerCase() == 'office'
                                ? Icons.work_rounded
                                : Icons.location_on_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      address.addressType.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Lufga',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D7A91).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1D7A91).withOpacity(0.2)),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        color: Color(0xFF1D7A91),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${address.addressLine1}${address.addressLine2 != null ? ', ${address.addressLine2}' : ''}, ${address.city}, ${address.pincode}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              address.phoneNumber,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: Colors.white.withOpacity(0.05)),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddAddressPage(address: address)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 14, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _deleteAddress(address.id),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red[300]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'No address added!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your delivery address to start shopping',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomButton(
        text: 'Add New Address',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          );
        },
      ),
    );
  }
}
