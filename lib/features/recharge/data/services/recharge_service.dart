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

      if (responseData is List) {
        methods = responseData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (responseData is Map<String, dynamic>) {
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
        'message': responseData is Map<String, dynamic>
            ? responseData['message']?.toString() ??
            'Topup methods loaded successfully'
            : 'Topup methods loaded successfully',
        'data': methods,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': <Map<String, dynamic>>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
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

      final serverMessage = data['message']?.toString();
      final serverError = data['error']?.toString();

      if (serverMessage != null && serverMessage.isNotEmpty) {
        return serverMessage;
      }

      if (serverError != null && serverError.isNotEmpty) {
        return serverError;
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Invalid server response';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.unknown:
        return e.message ?? 'Unexpected error occurred';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
    }
  }
}