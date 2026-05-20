import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';

class RechargeService {
  final DioClient _dioClient;

  RechargeService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getTopupMethods() async {
    try {
      final response = await _dioClient.get(ApiConfig.topupMethods);

      final responseData = response.data;
      List<Map<String, dynamic>> methods = [];

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];

        if (data is List) {
          methods = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      return {
        'success': true,
        'data': methods,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': <Map<String, dynamic>>[],
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
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    }

    return e.message ?? 'Unexpected error occurred';
  }
}