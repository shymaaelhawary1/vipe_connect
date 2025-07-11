import 'package:vipe_connect/models/user_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;

  ProfileLoaded(this.user);
}

class ProfileUpdated extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}
