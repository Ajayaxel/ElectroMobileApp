class ApiConstants {
  static const String baseUrl = 'https://electromobileappbackend-production.up.railway.app/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  // Home
  static const String home = '/home';
  // Brands
  static const String brands = '/brands';
  // Products
  static const String products = '/products';
  static const String popularSearches = '/products/popular-searches';

  // Cart
  static const String cart = '/cart';
  static const String addToCart = '/cart/add';
  static const String updateCart = '/cart/update';
  static const String removeFromCart = '/cart/remove';

  // Address
  static const String address = '/address';
  // Orders
  static const String placeOrder = '/orders/place';
  static const String userOrders = '/orders';
  // Wishlist
  static const String wishlist = '/wishlist';
  static const String toggleWishlist = '/wishlist/toggle';
  // Vehicles
  static const String vehicleBrands = '/vehicles/brands';
  static const String vehicleModels = '/vehicles/models';
  static const String modelTypes = '/vehicles/model-types';
  static const String modelCategories = '/vehicles/categories';
  static const String userVehicles = '/user/vehicles';
  static const String allVehicleData = '/vehicles/all-data';
}
