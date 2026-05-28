import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:prestaservicios/nucleo/env.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Env.dominio + "/",
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 120),
      contentType: Headers.jsonContentType,
    ),
  );

  /// 🔹 Método GET
  Future<Map<String, dynamic>> GET(
    String url, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      final response = await _dio.get(url, queryParameters: params);

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  /// 🔹 Método POST
  Future<Map<String, dynamic>> POST(String url, dynamic data) async {
    try {
      final response = await _dio.post(url, data: data);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  /// 🔹 Método PUT
  Future<Map<String, dynamic>> PUT(
    String url,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        return Map<String, dynamic>.from(jsonDecode(response.data));
      } else {
        return {
          'success': false,
          'mensaje': 'Respuesta inesperada del servidor',
          'raw': response.data,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'mensaje': e.message,
        'statusCode': e.response?.statusCode,
        'raw': e.response?.data,
      };
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  /// 🔹 Método DELETE
  Future<Map<String, dynamic>> DELETE(
    String url, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      final response = await _dio.delete(url, queryParameters: params);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return {'success': false, 'mensaje': e.toString()};
    }
  }

  /// ⚠️ Manejo de errores de Dio
  Map<String, dynamic> _handleError(DioException e) {
    print(e);
    if (e.response != null) {
      return {
        'success': false,
        'mensaje': e.response?.data['mensaje'] ?? 'Error del servidor',
        'status': e.response?.statusCode,
      };
    } else {
      return {
        'success': false,
        'mensaje': 'Sin conexión con el servidor o timeout',
      };
    }
  }
}
