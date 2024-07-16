class APIConstants {
  static const String baseUrl = 'https://administration.pythonanywhere.com/';
  // 'http://192.168.24.237:8000/';
  // Auth APIs
  static const String tokenAPI = '${baseUrl}api/token/';
  static const String refreshTokenAPI = '${baseUrl}api/token/refresh/';
  static const String verifyTokenAPI = '${baseUrl}api/token/verify/';
  static const String createAccountAPI = '${baseUrl}create-account/';
  static const String adminDetailsAPI = '${baseUrl}admin-details/';
  static const String policyAPI = '${baseUrl}policy/';
  static const String termsofUseAPI = '${baseUrl}terms-of-use/';

  // Product APIs
  static String fetchAllProductsAPI(String action, String query) =>
      '${baseUrl + action}/?name=$query';
  static String fetchProductDetailsAPI(int productId) =>
      '${baseUrl}product/$productId/';

  // Category APIs
  static const String fetchHomeCategoriesAPI =
      '${baseUrl}home-page-categories/';
  static const String fetchAllCategoriesAPI = '${baseUrl}all-categories/';
  static const String fetchHomeProductsAPI = '${baseUrl}home-page-products/';
  // Address APIs
  static const String userAddressAPI = '${baseUrl}user-address/';
  static String updatePrimaryAddressAPI(int addressId) =>
      '${baseUrl}is-primary/$addressId/';
  static const String saveAddressAPI = '${baseUrl}save-address/';
  static String deleteAddressAPI(int addressId) =>
      '${baseUrl}delete-address/$addressId/';
  static String deliverySelectedAddress(int id) =>
      '${baseUrl}single-address/$id/';
  // Cart APIs
  static const String addToCart = '${baseUrl}add-to-cart/';
  static const String totalCartQuantity = '${baseUrl}total-cart-items/';
  static const String cartQuantity = '${baseUrl}cart-quantity/';
  static String productInCartExistsAPI(
          int productId, String price, String discountedPrice) =>
      '${baseUrl}cart/product-exists/$productId/$price/$discountedPrice/';
  static String updateCartAPI(int cartItemId, int quantity) =>
      '${baseUrl}update-to-cart/$cartItemId/$quantity/';
  static String removeFromCartAPI(int cartItemId) =>
      '${baseUrl}cart-item/$cartItemId/delete/';
  static const String cartAPI = '${baseUrl}cart/';
  static const String verifyCartProductPrices =
      '${baseUrl}check-valid-cart-prices/';
  // Order APIs
  static const String placeOrder = '${baseUrl}place-order/';
  static const String orders = '${baseUrl}orders/';
  static String updateOrderAPI(int orderId) =>
      '${baseUrl}update-order/$orderId/';
  // PickupDrop APIs
  static const String createPickupDrop = '${baseUrl}create-pick-drop/';
  static const String listPickupDrop = '${baseUrl}pick-drop-list/';
}
