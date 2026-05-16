import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';

class WalletService {
  final DioClient _dioClient;

  WalletService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dioClient.get(ApiConfig.wallet);

      return {
        'success': true,
        'data': response.data['data'] ?? {},
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': {},
      };
    }
  }

  Future<Map<String, dynamic>> getTopupMethods() async {
    try {
      final response = await _dioClient.get(ApiConfig.topupMethods);

      return {
        'success': true,
        'data': response.data['data'] ?? [],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': [],
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