class Apiurls {
  // Base URL
  // static const String baseUrl =
  //     'https://test.affiliate.api.caremallonline.com'; // test
  static const String baseUrl =
      'https://affiliate.api.caremallonline.com'; // live

  static const String sendOtp = '$baseUrl/api/v1/affiliate/auth/send-otp';
  static const String verifyOtp = '$baseUrl/api/v1/affiliate/auth/verify-otp';
  static const String kycupdates = '$baseUrl/api/v1/affiliate/kyc';
  static const String profile = '$baseUrl/api/v1/affiliate/profile';
  static const String dashboardStats =
      '$baseUrl/api/v1/affiliate/dashboard/stats';
  static const String dashboardPerformance =
      '$baseUrl/api/v1/affiliate/dashboard/performance';
  static const String recentOrders = '$baseUrl/api/v1/affiliate/orders';
  static const String dashboardEarnings =
      '$baseUrl/api/v1/affiliate/dashboard/earnings';
  static const String dashboardSlab =
      '$baseUrl/api/v1/affiliate/dashboard/slab';
  static const String monthlyEarning =
      '$baseUrl/api/v1/affiliate/dashboard/monthly-earning';
  static const String productsList = '$baseUrl/api/v1/affiliate/products';
  static const String generateLink = '$baseUrl/api/v1/affiliate/products';
  static const String allLinks = '$baseUrl/api/v1/affiliate/links';
  static const String linksStats = '$baseUrl/api/v1/affiliate/links/stats';
  static const String returnOrders = '$baseUrl/api/v1/affiliate/orders/returns';
  static const String payouts = '$baseUrl/api/v1/affiliate/payouts';
}
