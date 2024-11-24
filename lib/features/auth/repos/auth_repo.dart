import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_3/core/classes/shared_pref.dart';
import 'package:flutter_application_3/core/constent/api_consts.dart';
import 'package:flutter_application_3/core/errors/errors.dart';
import 'package:flutter_application_3/features/auth/model/user_auth_modules.dart';

abstract class AuthRepo {
  Future<Either<ServerFailure, User>> signin(
      String name, String email, String password);
  Future<Either<ServerFailure, User>> login(String email, String password);
  Future<Either<ServerFailure, User>> getuserdata(String token);
}

class AuthImpl implements AuthRepo {
  final Dio dio;

  AuthImpl({required this.dio}) {
    dio.options.baseUrl = ApiConsts.base_url;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  Future<Either<ServerFailure, User>> login(
      String email, String password) async {
    try {
      final response = await dio.post(
        ApiConsts.login_path,
        data: {
          'email': email,
          'password': password,
        },
      );

      final userData = response.data['user'];
      final token = response.data['token'];

      await SharedPrefs.setString('auth_token', token);

      final user = User.fromMap(userData).copyWith(token: token);
      print(user);
      return Right(user);
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        return const Left(ServerFailure("Invalid email or password"));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ServerFailure, User>> signin(
      String name, String email, String password) async {
    try {
      final response = await dio.post(
        ApiConsts.signin_path,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      print('${response.data}');
      String jsonString = jsonEncode(response.data);
      return Right(User.fromJson(jsonString));
    } on DioException catch (e) {
      if (e.response != null && e.response?.statusCode == 400) {
        // Handle specific 400 error
        return const Left(ServerFailure("User already exists"));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('catch');
      return Left(
          ServerFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<ServerFailure, User>> getuserdata(String token) async {
    try {
      final response = await dio.get("auth/",
          options: Options(headers: {
            "x-auth": token,
          }));
      print(token);
      return Right(User.fromMap(response.data).copyWith(token: token));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
