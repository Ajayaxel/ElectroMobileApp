import 'package:electro/core/widgets/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/home/models/home_models.dart';
import 'package:electro/features/cart/bloc/cart_bloc.dart';
import 'package:electro/features/cart/bloc/cart_event_state.dart';
import 'package:electro/core/utils/custom_toast.dart';
import 'package:electro/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:electro/features/cart/models/cart_model.dart';
import 'package:electro/features/cart/presentation/pages/checkout_page.dart';
import 'package:electro/features/cart/presentation/pages/cart_screen.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;
  bool _isBuyNowTriggered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartActionSuccess) {
          CustomToast.showSuccess(context, state.message);
          if (_isBuyNowTriggered) {
            setState(() {
              _isBuyNowTriggered = false;
            });
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckoutPage(cart: state.cart),
              ),
            );
          }
        } else if (state is CartError) {
          CustomToast.showError(context, state.message);
          if (_isBuyNowTriggered) {
            setState(() {
              _isBuyNowTriggered = false;
            });
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen(showBackButton: true)),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // Product Image Container
                        Container(
                          width: double.infinity,
                          height: 380,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A0A0A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF1D7A91).withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Hero(
                              tag: 'product_image_${product.id}',
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: AppNetworkImage(
                                  url: product.image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '[28.6k]',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // New Arrival Tag
                        const Text(
                          'New Arrival',
                          style: TextStyle(
                            color: Color(0xFF1D7A91),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'AED ${product.price.toInt()}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(incl. of all taxes)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Text(
                          product.description.isEmpty
                              ? 'High-performance automotive battery designed for reliable starting power and long-lasting durability. Suitable for a wide range of passenger vehicles with consistent performance in all weather conditions.'
                              : product.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.5),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: BlocBuilder<CartBloc, CartState>(
                                builder: (context, cartState) {
                                  final isSubmitting = cartState is CartSubmitting && _isBuyNowTriggered;
                                  return OutlinedButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            bool isInCart = false;
                                            CartModel? currentCart;

                                            if (cartState is CartLoaded) {
                                              isInCart = cartState.cart.items.any((item) => item.product.id == product.id);
                                              currentCart = cartState.cart;
                                            } else if (cartState is CartActionSuccess) {
                                              isInCart = cartState.cart.items.any((item) => item.product.id == product.id);
                                              currentCart = cartState.cart;
                                            }

                                            if (isInCart && currentCart != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => CheckoutPage(cart: currentCart!),
                                                ),
                                              );
                                            } else {
                                              setState(() {
                                                _isBuyNowTriggered = true;
                                              });
                                              context.read<CartBloc>().add(
                                                    AddToCart(
                                                      productId: product.id,
                                                      quantity: 1,
                                                    ),
                                                  );
                                            }
                                          },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Buy Now',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: BlocBuilder<CartBloc, CartState>(
                                builder: (context, cartState) {
                                  bool isInCart = false;
                                  CartModel? currentCart;

                                  if (cartState is CartLoaded) {
                                    isInCart = cartState.cart.items.any((item) => item.product.id == product.id);
                                    currentCart = cartState.cart;
                                  } else if (cartState is CartActionSuccess) {
                                    isInCart = cartState.cart.items.any((item) => item.product.id == product.id);
                                    currentCart = cartState.cart;
                                  }

                                  return ElevatedButton(
                                    onPressed: () {
                                      if (isInCart) {
                                        if (currentCart != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CheckoutPage(cart: currentCart!),
                                            ),
                                          );
                                        }
                                      } else {
                                        context.read<CartBloc>().add(
                                              AddToCart(
                                                productId: product.id,
                                                quantity: 1,
                                              ),
                                            );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1D7A91),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      isInCart ? 'Checkout' : 'Add to cart',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Specifications Accordion
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              unselectedWidgetColor: Colors.white,
                              colorScheme: const ColorScheme.dark(),
                            ),
                            child: ExpansionTile(
                              title: const Text(
                                'Specifications',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              children: [
                                _buildSpecRow(
                                  'Type',
                                  product.type.toUpperCase(),
                                ),
                                _buildSpecRow(
                                  'Battery Type',
                                  product.batteryType,
                                ),
                                _buildSpecRow('AH (C20)', product.ah),
                                _buildSpecRow('CCA (-18° C)', product.cca),
                                _buildSpecRow(
                                  'Part Number',
                                  product.partNumber,
                                ),
                                _buildSpecRow('Warranty', product.warranty),
                                _buildSpecRow('Voltage', product.voltage),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildSpecRow(String label, String value) {
    if (value.isEmpty || value == 'N/A') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
