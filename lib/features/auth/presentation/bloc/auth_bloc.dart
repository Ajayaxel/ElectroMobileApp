import 'package:electro/core/utils/shared_prefs_util.dart';
import 'package:electro/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final isLoggedIn = await SharedPrefsUtil.isLoggedIn();
      if (isLoggedIn) {
        add(ProfileRequested());
      }
    });

    on<ProfileRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await SharedPrefsUtil.getToken();
        if (token != null) {
          final user = await authRepository.getProfile(token);
          emit(AuthSuccess(user));
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains("Cannot destructure property 'id' of 'req.user'") ||
            errStr.contains("No token found") ||
            errStr.contains("unauthorized") ||
            errStr.contains("Not authorized") ||
            errStr.contains("user not found")) {
          await SharedPrefsUtil.clearToken();
          emit(AuthInitial());
        } else {
          emit(AuthFailure(e.toString()));
        }
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.register(
          name: event.name,
          email: event.email,
          phone: event.phone,
          password: event.password,
          confirmPassword: event.confirmPassword,
        );
        await SharedPrefsUtil.saveToken(user.token);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(
          email: event.email,
          password: event.password,
        );
        await SharedPrefsUtil.saveToken(user.token);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await SharedPrefsUtil.clearToken();
      emit(AuthInitial());
    });

    on<UpdateProfileRequested>((event, emit) async {
      final currentState = state;
      if (currentState is AuthSuccess) {
        // We emit a separate loading if we don't want to hide the whole screen
        // But for now, let's use AuthLoading to be safe
        emit(AuthLoading());
        try {
          final token = await SharedPrefsUtil.getToken();
          if (token != null) {
            final user = await authRepository.updateProfile(
              token: token,
              name: event.name,
              email: event.email,
              phone: event.phone,
              currentPassword: event.currentPassword,
              newPassword: event.newPassword,
              imagePath: event.imagePath,
            );
            await SharedPrefsUtil.saveToken(user.token);
            emit(AuthSuccess(user));
          } else {
            emit(AuthInitial());
          }
        } catch (e) {
          emit(AuthFailure(e.toString()));
          // After a failure, we should probably return to the previous success state
          // so the user can try again without losing their view
          emit(AuthSuccess(currentState.user));
        }
      }
    });

    on<DeleteAccountRequested>((event, emit) async {
      final currentState = state;
      emit(AuthLoading());
      try {
        final token = await SharedPrefsUtil.getToken();
        if (token != null) {
          await authRepository.deleteAccount(token);
          await SharedPrefsUtil.clearToken();
          emit(AuthInitial());
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        emit(AuthFailure(e.toString()));
        if (currentState is AuthSuccess) {
          emit(AuthSuccess(currentState.user));
        } else {
          emit(AuthInitial());
        }
      }
    });
  }
}
