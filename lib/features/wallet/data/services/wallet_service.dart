import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';

class WalletService {
  final DioClient _dioClient;

  WalletService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dioClient.get(ApiConfig.wallet);

      final responseData = response.data;
      Map<String, dynamic> walletData = {};

      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] is Map<String, dynamic>) {
          walletData = Map<String, dynamic>.from(responseData['data']);
        } else {
          walletData = Map<String, dynamic>.from(responseData);
        }
      }

      return {
        'success': true,
        'data': walletData,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': <String, dynamic>{},
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': <String, dynamic>{},
      };
    }
  }

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
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': <Map<String, dynamic>>[],
      };
    }
  }

  Future<Map<String, dynamic>> getTransactions({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.walletTransactions,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      final responseData = response.data;
      List<Map<String, dynamic>> items = [];

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];

        if (data is List) {
          items = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          items = (data['data'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      return {
        'success': true,
        'data': items,
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

  Future<Map<String, dynamic>> createTopupRequest({
    required int walletId,
    required int topupMethodId,
    required num amount,
    String? senderName,
    String? senderAccount,
    String? transferReference,
    String? receiptImage,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.walletTopups,
        data: {
          'wallet_id': walletId,
          'topup_method_id': topupMethodId,
          'amount': amount,
          'sender_name': senderName,
          'sender_account': senderAccount,
          'transfer_reference': transferReference,
          'receipt_image': receiptImage,
          'notes': notes,
        },
      );

      final responseData = response.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};

      return {
        'success': true,
        'message': responseData['message'] ?? 'Topup request created successfully',
        'data': responseData['data'] ?? responseData,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _extractMessage(e),
        'data': <String, dynamic>{},
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': <String, dynamic>{},
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