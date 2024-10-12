part of 'user_auth_cubit.dart';

sealed class UserAuthState extends Equatable {
  const UserAuthState();

  @override
  List<Object> get props => [];
}

final class UserAuthInitial extends UserAuthState {}

final class UserAuthIsLoading extends UserAuthState {}

final class UserAuthSuccess extends UserAuthState {
  final User user;

  const UserAuthSuccess(this.user);
}

final class UserAuthFailed extends UserAuthState {
  final String errormessage;

  const UserAuthFailed(this.errormessage);
}
