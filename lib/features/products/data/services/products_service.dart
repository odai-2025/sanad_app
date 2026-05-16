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

  Future<Map<String, dynamic>> getServiceDetails(int serviceId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.serviceDetails(serviceId),
      );

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