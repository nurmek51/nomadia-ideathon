import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService._internal()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _resolveBaseUrl(),
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 12),
            headers: const {'Accept': 'application/json'},
          ),
        );

  static final ApiService instance = ApiService._internal();

  final Dio _dio;

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8000',
      _ => 'http://127.0.0.1:8000',
    };
  }

  Future<Map<String, dynamic>> getDemoState() => _getMap('/demo/state');
  Future<Map<String, dynamic>> getDashboard() => _getMap('/dashboard');
  Future<void> resetDemo() async => _postMap('/demo/reset');
  Future<Map<String, dynamic>> getInventory() => _getMap('/inventory');
  Future<Map<String, dynamic>> getAidCredits(String residentId) =>
      _getMap('/aid-credits/$residentId');
  Future<Map<String, dynamic>> getLatestResidentRequest(String residentId) =>
      _getMap('/resident/$residentId/latest-request');
  Future<Map<String, dynamic>> getRequest(int requestId) =>
      _getMap('/requests/$requestId');
  Future<Map<String, dynamic>> getRequestStatusView(int requestId) =>
      _getMap('/requests/$requestId/status-view');

  Future<List<dynamic>> listRequests({
    String? role,
    String? status,
    String? village,
  }) =>
      _getList(
        '/requests',
        queryParameters: {
          if (role != null) 'role': role,
          if (status != null) 'status': status,
          if (village != null) 'village': village,
        },
      );

  Future<List<dynamic>> getSupplierTasks({
    String? supplierNode,
    String? status,
  }) =>
      _getList(
        '/supplier/tasks',
        queryParameters: {
          if (supplierNode != null) 'supplier_node': supplierNode,
          if (status != null) 'status': status,
        },
      );

  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> body) =>
      _postMap('/requests', data: body);
  Future<Map<String, dynamic>> verifyRequest(int requestId) =>
      _postMap('/requests/$requestId/verify');
  Future<Map<String, dynamic>> prioritizeRequest(int requestId) =>
      _postMap('/requests/$requestId/prioritize');
  Future<Map<String, dynamic>> matchRequest(int requestId) =>
      _postMap('/requests/$requestId/match');
  Future<Map<String, dynamic>> approveDelivery(int requestId) =>
      _postMap('/requests/$requestId/approve-delivery');
  Future<Map<String, dynamic>> completeDelivery(int deliveryId) =>
      _postMap('/deliveries/$deliveryId/complete');
  Future<Map<String, dynamic>> updateInventory(Map<String, dynamic> body) =>
      _patchMap('/inventory/update', data: body);
  Future<Map<String, dynamic>> issueInventory(Map<String, dynamic> body) =>
      _postMap('/inventory/issue', data: body);
  Future<Map<String, dynamic>> supplierAcceptRequest(Map<String, dynamic> body) =>
      _postMap('/supplier/accept-request', data: body);

  Future<Map<String, dynamic>> _getMap(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const ApiException('Некорректный ответ API');
    } on DioException catch (error) {
      throw ApiException(_extractMessage(error));
    }
  }

  Future<List<dynamic>> _getList(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is List<dynamic>) {
        return data;
      }
      throw const ApiException('Некорректный ответ API');
    } on DioException catch (error) {
      throw ApiException(_extractMessage(error));
    }
  }

  Future<Map<String, dynamic>> _postMap(
    String path, {
    Object? data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      throw const ApiException('Некорректный ответ API');
    } on DioException catch (error) {
      throw ApiException(_extractMessage(error));
    }
  }

  Future<Map<String, dynamic>> _patchMap(
    String path, {
    Object? data,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(path, data: data);
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      throw const ApiException('Некорректный ответ API');
    } on DioException catch (error) {
      throw ApiException(_extractMessage(error));
    }
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return error.message ?? 'Ошибка сети';
  }
}
