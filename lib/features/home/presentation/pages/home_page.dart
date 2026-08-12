import 'dart:async';
import 'package:electro/core/widgets/app_network_image.dart';
import 'package:electro/core/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/home_bloc.dart';
import '../../bloc/home_event_state.dart';
import '../../models/home_models.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../../../product/presentation/pages/all_products_page.dart';
import '../../../product/presentation/pages/brand_filter_page.dart';
import '../../../product/presentation/pages/search_screen.dart';
import 'package:electro/core/widgets/global_header.dart';
import 'package:electro/features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'package:electro/core/widgets/shimmer_placeholder.dart';
import '../widgets/home_shimmer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeView();
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentBannerPage = 0;
  int _selectedBrandIndex = 0;
  Timer? _bannerTimer;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Only fetch if we are in the initial state or if there was an error.
    // This prevents overcalling when the widget is rebuilt or when navigating between tabs.
    final homeBloc = context.read<HomeBloc>();
    if (homeBloc.state is HomeInitial || homeBloc.state is HomeError) {
      homeBloc.add(FetchHomeData());
    }

    _startBannerAutoScroll();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final homeBloc = context.read<HomeBloc>();
      if (homeBloc.state is HomeLoaded) {
        final banners = (homeBloc.state as HomeLoaded).data.banners;
        if (banners.length > 1) {
          _currentBannerPage = (_currentBannerPage + 1) % banners.length;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentBannerPage,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutQuart,
            );
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _searchController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HomeBloc>().add(LoadMoreHomeData());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D7A91), Colors.black],
            stops: [0.0, 0.4],
          ),
        ),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const HomeShimmer();
            }

            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load data',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          context.read<HomeBloc>().add(FetchHomeData()),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              final rawItems = state.data.sections
                  .expand((s) => s.items)
                  .toList();
              final items = _searchQuery.isEmpty
                  ? rawItems
                  : rawItems
                        .where(
                          (item) =>
                              item.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ) ||
                              item.brand.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                        )
                        .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(FetchHomeData());
                },
                color: const Color(0xFF1D7A91),
                backgroundColor: Colors.black,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 10,
                        bottom: 0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SafeArea(
                          bottom: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const GlobalHeader(),
                              const SizedBox(height: 16),
                              _buildCustomSearchBar(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_searchQuery.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 16,
                          ),
                          child: _buildBanners(state.data.banners),
                        ),
                      ),
                    if (_searchQuery.isEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Brands",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBrandSelector(state.data.brands, items),
                                ],
                              ),
                              const SizedBox(height: 22),
                              _buildSectionHeader(
                                context,
                                'Recently Added',
                                items,
                              ),
                              const SizedBox(height: 16),
                              _buildRecentlyAddedList(items),
                              const SizedBox(height: 16),
                              _buildSectionHeader(
                                context,
                                'Popular Batteries',
                                items,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Text(
                                    'Search Results',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Lufga',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${items.length})',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    if (items.isEmpty)
                      const SliverPadding(
                        padding: EdgeInsets.only(top: 40, bottom: 80),
                        sliver: SliverToBoxAdapter(
                          child: EmptyStateWidget(
                            title: 'No Products Available',
                            description:
                                'We couldn\'t find any products in our catalog right now. Try checking another category or refresh the page.',
                            actionLabel: 'Refresh Content',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return _buildProductCard(
                              context,
                              items[index],
                              'popular_',
                            );
                          }, childCount: items.length),
                        ),
                      ),
                    if (state.isFetchingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1D7A91),
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildCustomSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white60, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(
                  color: Colors.white30,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                FocusScope.of(context).unfocus();
              },
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white38,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    List<ProductModel> items,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AllProductsPage(products: items, title: title),
              ),
            );
          },
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyAddedList(List<ProductModel> products) {
    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length > 5 ? 5 : products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 170,
            child: _buildProductCard(context, products[index], 'recent_'),
          );
        },
      ),
    );
  }

  Widget _buildBrandSelector(
    List<BrandModel> brands,
    List<ProductModel> items,
  ) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          final bool isSelected = _selectedBrandIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedBrandIndex = index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BrandFilterPage(
                    brandName: brand.name,
                    allProducts: items,
                  ),
                ),
              );
            },
            child: Container(
              height: 52,
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1D7A91)
                      : const Color(0xffffffff).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: AppNetworkImage(
                      url: brand.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      brand.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF1D7A91)
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanners(List<BannerModel> banners) {
    if (banners.isEmpty) return _buildPlaceholderBanner();

    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) =>
                setState(() => _currentBannerPage = index),
            itemCount: banners.length,
            itemBuilder: (context, index) => _buildBannerItem(banners[index]),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentBannerPage == index
                    ? const Color(0xFF1D7A91)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerItem(BannerModel banner) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (banner.image.isNotEmpty)
              Image.network(
                banner.image,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                opacity: const AlwaysStoppedAnimation(0.3),
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white30,
                      size: 40,
                    ),
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      banner.subtitle.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Ultimate Power For",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      "Your Vehicle",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A3A5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Grab now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      height: 170,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Colors.black, Color(0xFF1D7A91)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ultimate Power For',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const Text(
                'Your Vehicle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Premium Battery Solutions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF38A4B6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Grab now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    String tagPrefix,
  ) {
    return _ProductCard(product: product, tagPrefix: tagPrefix);
  }
}

class _ProductCard extends StatefulWidget {
  final ProductModel product;
  final String tagPrefix;
  const _ProductCard({required this.product, required this.tagPrefix});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  @override
  void didUpdateWidget(_ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.isFavorite != widget.product.isFavorite) {
      _isFavorite = widget.product.isFavorite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Hero(
                        tag: '${widget.tagPrefix}${product.id}',
                        child: AppNetworkImage(
                          url: product.image,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const ShimmerPlaceholder(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isFavorite = !_isFavorite);
                        context.read<WishlistBloc>().add(
                          ToggleWishlistEvent(product.id),
                        );
                      },
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        size: 22,
                        color: _isFavorite ? Colors.red : Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Best seller',
                    style: TextStyle(color: Color(0xFF1D7A91), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AED ${product.price.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D7A91),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
