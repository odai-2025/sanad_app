import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/network/dio_client.dart';

class ProductsService {
  final DioClient _dioClient;

  ProductsService({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient();

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _dioClient.get(ApiConfig.categories);
      final responseData = response.data;

      List<Map<String, dynamic>> categories = [];

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];

        if (data is List) {
          categories = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      return {
        'success': true,
        'data': categories,
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

  Future<Map<String, dynamic>> getServices({
    int? categoryId,
    String? serviceType,
  }) async {
    try {
      final query = <String, dynamic>{};

      if (categoryId != null) {
        query['category_id'] = categoryId;
      }

      if (serviceType != null && serviceType.isNotEmpty) {
        query['service_type'] = serviceType;
      }

      final response = await _dioClient.get(
        ApiConfig.services,
        queryParameters: query,
      );

      final responseData = response.data;
      List<Map<String, dynamic>> services = [];

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];

        if (data is List) {
          services = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }

      return {
        'success': true,
        'data': services,
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

  Future<Map<String, dynamic>> getServiceDetails(int serviceId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.serviceDetails(serviceId),
      );

      final responseData = response.data;
      Map<String, dynamic> service = {};

      if (responseData is Map<String, dynamic>) {
        final data = responseData['data'];

        if (data is Map<String, dynamic>) {
          service = Map<String, dynamic>.from(data);
        }
      }

      return {
        'success': true,
        'data': service,
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