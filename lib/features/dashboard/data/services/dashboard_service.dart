import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';

class DashboardService {
  final DioClient _dioClient;

  DashboardService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConfig.me);

      return {
        'success': true,
        'data': response.data['data'] ?? response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dioClient.get(ApiConfig.wallet);

      return {
        'success': true,
        'data': response.data['data'] ?? response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
      };
    }
  }

  Future<Map<String, dynamic>> getOrders() async {
    try {
      final response = await _dioClient.get(ApiConfig.orders);

      return {
        'success': true,
        'data': response.data['data'] ?? response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
      };
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    return e.message ?? 'Unexpected error occurred';
  }
}