import 'package:dio/dio.dart';
import 'package:sanad_app/core/constants/api_config.dart';
import 'package:sanad_app/core/network/dio_client.dart';

class OrdersService {
  final DioClient _dioClient;

  OrdersService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> createOrder({
    required int serviceId,
    required String targetAccount,
    required num amount,
    String? customerName,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.orders,
        data: {
          'service_id': serviceId,
          'target_account': targetAccount,
          'amount': amount,
          if (customerName != null && customerName.trim().isNotEmpty)
            'customer_name': customerName.trim(),
          if (extraData != null) 'extra_data': extraData,
        },
      );

      final responseData = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};

      return {
        'success': true,
        'message': responseData['message']?.toString() ??
            'Order created successfully',
        'data': responseData['data'] ?? responseData,
      };
    } on DioException catch (e) {
      final data = e.response?.data;

      String message = _extractMessage(e);

      if (data is Map<String, dynamic>) {
        final serverMessage = data['message']?.toString();
        final serverError = data['error']?.toString();

        if (serverMessage != null &&
            serverMessage.isNotEmpty &&
            serverError != null &&
            serverError.isNotEmpty) {
          message = '$serverMessage | $serverError';
        } else if (serverMessage != null && serverMessage.isNotEmpty) {
          message = serverMessage;
        } else if (serverError != null && serverError.isNotEmpty) {
          message = serverError;
        }
      }

      return {
        'success': false,
        'message': message,
        'data': data ?? {},
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': {},
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

      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['error'] != null) {
        return data['error'].toString();
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