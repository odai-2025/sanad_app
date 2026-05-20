import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';

class TransactionsService {
  final DioClient _dioClient;

  TransactionsService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getWalletTransactions() async {
    try {
      final response = await _dioClient.get(ApiConfig.walletTransactions);
      final responseData = response.data;

      if (responseData is Map<String, dynamic>) {
        return {
          'success': true,
          'data': responseData['data'] ?? [],
          'message': responseData['message'],
        };
      }

      if (responseData is List) {
        return {
          'success': true,
          'data': responseData,
          'message': null,
        };
      }

      return {
        'success': false,
        'message': 'Unexpected response format',
        'data': [],
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
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

      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstValue = errors.values.isNotEmpty ? errors.values.first : null;

        if (firstValue is List && firstValue.isNotEmpty) {
          return firstValue.first.toString();
        }

        if (firstValue != null) {
          return firstValue.toString();
        }
      }
    }

    return e.message ?? 'Unexpected error occurred';
  }
}