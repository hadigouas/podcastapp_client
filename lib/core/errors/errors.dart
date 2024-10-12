import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class ServerFailure extends Equatable {
  final String message;
  const ServerFailure(this.message);

  @override
  List<Object?> get props => [message];

  factory ServerFailure.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('Connection timeout with API server');
      case DioExceptionType.sendTimeout:
        return const ServerFailure('Send timeout with API server');
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Receive timeout with API server');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
            dioError.response?.statusCode, dioError.response?.data);
      case DioExceptionType.cancel:
        return const ServerFailure('Request to API server was cancelled');
      case DioExceptionType.connectionError:
        return const ServerFailure('No Internet Connection');
      case DioExceptionType.unknown:
        if (dioError.error != null && dioError.error.toString().contains('SocketException')) {
          return const ServerFailure('No Internet Connection');
        }
        return const ServerFailure('Unexpected Error, Please try again!');
      default:
        return const ServerFailure('Oops! There was an Error, Please try again');
    }
  }

  factory ServerFailure.fromResponse(int? statusCode, dynamic response) {
    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return ServerFailure(response['error']['message'] ?? 'Authentication Error');
    } else if (statusCode == 404) {
      return const ServerFailure('Your request was not found, Please try later!');
    } else if (statusCode == 500) {
      return const ServerFailure('Internal Server error, Please try later');
    } else {
      return const ServerFailure('Oops! There was an Error, Please try again');
    }
  }
}