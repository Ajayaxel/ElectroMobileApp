import 'package:electro/core/theme/app_colors.dart';
import 'package:electro/widgets/custom_button.dart';
import 'package:electro/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/cart/bloc/cart_bloc.dart';
import 'package:electro/features/cart/bloc/cart_event_state.dart';
import 'package:electro/features/cart/models/cart_model.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/core/widgets/global_header.dart';
import 'package:electro/features/cart/presentation/pages/checkout_page.dart';
import 'package:electro/features/product/presentation/pages/all_products_page.dart';

class CartScreen extends StatefulWidget {
  final bool showBackButton;
  const CartScreen({super.key, this.showBackButton = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(FetchCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartError) {
              CustomToast.showError(context, state.message);
            } else if (state is CartActionSuccess) {
              CustomToast.showSuccess(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is CartLoading && state is! CartLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            if (state is CartError && state is! CartLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<CartBloc>().add(FetchCart()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            CartModel? cart;
            if (state is CartLoaded) {
              cart = state.cart;
            } else if (state is CartActionSuccess) {
              cart = state.cart;
            }

            final currentCart = cart;
            if (currentCart == null || currentCart.items.isEmpty) {
              return _buildEmptyCart();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlobalHeader(showBackButton: widget.showBackButton),
                  const SizedBox(height: 24),
                  const Text(
                    'My Cart',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lufga',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: currentCart.items.length,
                      itemBuilder: (context, index) {
                        final item = currentCart.items[index];
                        return _buildCartItem(item);
                      },
                    ),
                  ),
                  _buildCheckoutSection(currentCart),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: GlobalHeader(showBackButton: widget.showBackButton),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    size: 80,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lufga',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Looks like you haven\'t added\nanything to your cart yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AllProductsPage(title: 'All Batteries'),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Start Shopping',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: AppNetworkImage(
              url: item.product.image,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          // Details
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
                    fontFamily: 'Lufga',
                  ),
                ),
                Text(
                  item.product.brand,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AED ${item.price.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () {
                  context.read<CartBloc>().add(
                    RemoveFromCart(productId: item.product.id),
                  );
                },
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      if (item.quantity > 1) {
                        context.read<CartBloc>().add(
                          UpdateCartQuantity(
                            productId: item.product.id,
                            quantity: item.quantity - 1,
                          ),
                        );
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      context.read<CartBloc>().add(
                        UpdateCartQuantity(
                          productId: item.product.id,
                          quantity: item.quantity + 1,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildCheckoutSection(CartModel cart) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Items (${cart.totalItems})',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              'AED ${cart.totalPrice.toInt()}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: "Checkout Now",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CheckoutPage(cart: cart)),
            );
          },
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
