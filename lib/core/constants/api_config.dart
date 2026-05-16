class ApiConfig {
  static const String baseUrl = 'http://localhost:8000/api';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String me = '/me';
  static const String logout = '/logout';

  // Categories & Services
  static const String categories = '/categories';
  static const String services = '/services';
  static String serviceDetails(int id) => '/services/$id';

  // Wallet
  static const String wallet = '/wallet';
  static const String walletTransactions = '/wallet/transactions';

  // Orders
  static const String orders = '/orders';

  // Topup
  static const String topupMethods = '/topup-methods';
}