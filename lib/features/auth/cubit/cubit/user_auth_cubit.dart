import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_3/core/classes/shared_pref.dart';
import 'package:flutter_application_3/features/auth/model/user_auth_modules.dart';
import 'package:flutter_application_3/features/auth/repos/auth_repo.dart';

part 'user_auth_state.dart';

class UserAuthCubit extends Cubit<UserAuthState> {
  final AuthRepo _authRepo;
  UserAuthCubit(this._authRepo) : super(UserAuthInitial());

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const UserAuthFailed('Fields cannot be empty'));
      return;
    }

    emit(UserAuthIsLoading());
    final response = await _authRepo.login(email, password);

    response.fold(
      (l) => emit(UserAuthFailed(l.message)),
      (r) => emit(UserAuthSuccess(r)),
    );
  }

  Future<void> signUp(String name, String email, String password) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      emit(const UserAuthFailed('Fields cannot be empty'));
      return;
    }

    emit(UserAuthIsLoading());
    final result = await _authRepo.signin(name, email, password);
    result.fold(
      (failure) => emit(UserAuthFailed(failure.message)),
      (user) => emit(UserAuthSuccess(user)),
    );
  }

  Future<void> fetchAndHandleUserData() async {
    final token = SharedPrefs.getString("auth_token");

    if (token.isNotEmpty) {
      final result = await _authRepo.getuserdata(token);

      result.fold(
        (failure) {
          emit(UserAuthFailed(failure.message));
        },
        (user) {
          emit(UserAuthSuccess(user));
        },
      );
    } else {
      emit(const UserAuthFailed("Token not found"));
    }
  }
}
