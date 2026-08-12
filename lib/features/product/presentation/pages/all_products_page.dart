import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:electro/core/constants/api_constants.dart';
import 'package:electro/core/services/api_service.dart';
import 'package:electro/features/home/models/home_models.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_shimmer.dart';
import 'package:electro/core/widgets/empty_state_widget.dart';

class AllProductsPage extends StatefulWidget {
  final List<ProductModel>? products;
  final String title;

  const AllProductsPage({
    super.key,
    this.products,
    this.title = 'All Products',
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final ApiService _apiService = ApiService();
  final List<ProductModel> _allLoadedProducts = [];
  List<ProductModel> _displayProducts = [];

  bool _isLoading = false;
  bool _isFetchingMore = false;
  bool _hasError = false;
  String _errorMessage = '';

  bool _hasReachedMax = false;
  int _currentPage = 1;
  final int _limit = 10;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.products != null) {
      _allLoadedProducts.addAll(widget.products!);
      _displayProducts = List.from(_allLoadedProducts);
      _hasReachedMax = widget.products!.length < _limit;
    } else {
      _fetchInitialProducts();
    }

    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isFetchingMore &&
          !_hasReachedMax &&
          _searchController.text.isEmpty &&
          !_hasError) {
        _fetchMoreProducts();
      }
    }
  }

  Future<void> _fetchInitialProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentPage = 1;
    });

    try {
      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: {'page': _currentPage, 'limit': _limit},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final pagination = response.data['pagination'];

      setState(() {
        _allLoadedProducts.clear();
        _allLoadedProducts.addAll(
          data.map((json) => ProductModel.fromJson(json)).toList(),
        );
        _displayProducts = List.from(_allLoadedProducts);
        _hasReachedMax = _currentPage >= (pagination['pages'] ?? 1);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _fetchMoreProducts() async {
    setState(() => _isFetchingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: {'page': nextPage, 'limit': _limit},
      );

      final List<dynamic> data = response.data['data'] ?? [];
      final pagination = response.data['pagination'];

      setState(() {
        final newItems = data
            .map((json) => ProductModel.fromJson(json))
            .toList();
        _allLoadedProducts.addAll(newItems);
        _displayProducts = List.from(_allLoadedProducts);
        _currentPage = nextPage;
        _hasReachedMax = _currentPage >= (pagination['pages'] ?? 1);
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() => _isFetchingMore = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _displayProducts = List.from(_allLoadedProducts);
      } else {
        _displayProducts = _allLoadedProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query) ||
                  p.brand.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildGlassSearchBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerGrid();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _fetchInitialProducts,
      color: const Color(0xFF1D7A91),
      backgroundColor: Colors.black,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${_displayProducts.length} items found',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          if (_displayProducts.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(
                    product: _displayProducts[index],
                    onFavoriteToggle: () {
                      // Handled by local state or Bloc in real apps
                    },
                  ),
                  childCount: _displayProducts.length,
                ),
              ),
            ),
          if (_isFetchingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1D7A91),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const ProductCardShimmer(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.cloud_off_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
          ),
          const SizedBox(height: 24),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _fetchInitialProducts,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1D7A91),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Retry Again',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
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
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Lufga',
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.3), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Search in ${widget.title.split(' ').last}...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchController.text.isEmpty ? Icons.inventory_2_outlined : Icons.search_off_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Products Found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _searchController.text.isEmpty
                  ? 'Our catalog is currently empty. Please check back later for new arrivals.'
                  : 'We couldn\'t find any matches for "${_searchController.text}".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _searchController.text.isEmpty ? _fetchInitialProducts : () => setState(() => _searchController.clear()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1D7A91),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _searchController.text.isEmpty ? 'Refresh Catalog' : 'Clear Search',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
