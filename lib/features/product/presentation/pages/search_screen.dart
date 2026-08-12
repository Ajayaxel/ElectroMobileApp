import 'package:electro/core/widgets/app_network_image.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:electro/core/constants/api_constants.dart';
import 'package:electro/features/home/models/home_models.dart';
import 'package:electro/core/widgets/global_header.dart';
import 'product_details_page.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoadingProducts = true;
  List<String> _popularSearches = [];
  bool _isLoadingPopular = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _fetchData();
    _searchController.addListener(_onSearchChanged);
    
    // If there's an initial query, trigger the filter immediately after the first frame
    if (widget.initialQuery != null) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        _onSearchChanged();
      });
    }
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchProducts(), _fetchPopularSearches()]);
  }

  Future<void> _fetchProducts() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.get(ApiConstants.products);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (mounted) {
          setState(() {
            _allProducts = data
                .map((json) => ProductModel.fromJson(json))
                .toList();
            _isLoadingProducts = false;
            
            // If we have an initial query from home, filter immediately after products load
            if (widget.initialQuery != null) {
              final query = widget.initialQuery!.toLowerCase();
              _filteredProducts = _allProducts
                  .where((p) =>
                      p.name.toLowerCase().contains(query) ||
                      p.brand.toLowerCase().contains(query) ||
                      p.type.toLowerCase().contains(query))
                  .toList();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _fetchPopularSearches() async {
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.get(ApiConstants.popularSearches);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (mounted) {
          setState(() {
            _popularSearches = data.map((e) => e.toString()).toList();
            _isLoadingPopular = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _popularSearches = [
            'Exide',
            'Amaron',
            'Car Battery',
            'Bike',
            'Lithium',
          ];
          _isLoadingPopular = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = [];
      } else {
        _filteredProducts = _allProducts
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query) ||
                  p.brand.toLowerCase().contains(query) ||
                  p.type.toLowerCase().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GlobalHeader(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _searchController.text.isEmpty ? 'Search' : 'Search Results',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Lufga',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSearchField(),
                ],
              ),
            ),
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildInitialState()
                  : (_isLoadingProducts)
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1D7A91),
                      ),
                    )
                  : _filteredProducts.isEmpty
                  ? _buildEmptyResults()
                  : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.3),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'What are you looking for?',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 20,
              ),
              onPressed: () => _searchController.clear(),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 20),
          if (_isLoadingPopular)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1D7A91)),
            )
          else if (_popularSearches.isEmpty)
            Text(
              'Searching for trends...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 13,
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _popularSearches
                  .map((tag) => _buildSearchTag(tag))
                  .toList(),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchTag(String tag) {
    return GestureDetector(
      onTap: () {
        _searchController.text = tag;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: tag.length),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
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
              Icons.search_off_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No matches found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lufga',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep calm and try another search term',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
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
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF151515),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Hero(
                    tag: 'product_image_${product.id}',
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AppNetworkImage(
                        url: product.image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Lufga',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'AED ${product.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
