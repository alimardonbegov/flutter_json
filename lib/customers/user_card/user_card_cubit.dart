import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import '../user_data/user_data_cubit.dart';

class UserCardCubit extends Cubit<UserCardCubitState> {
  final ChosenUserCubit chosenUserCubit;
  late StreamSubscription<ChosenUserCubitState> _sub;

  UserCardCubit(
    this.chosenUserCubit,
  ) : super(UserCardCubitStateInit()) {
    _sub = chosenUserCubit.stream.listen((ChosenUserCubitState chosenUserState) {
      if (chosenUserState is ChosenUserCubitStateReady) {
        emit(UserCardCubitStateReady(chosenUserState.data, chosenUserState.id));
      } else if (chosenUserState is ChosenUserCubitStateError) {
        emit(UserCardCubitStateError(chosenUserState.error, chosenUserState.data, chosenUserState.id));
      }
    });
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

@immutable
abstract class UserCardCubitState {
  final Map<String, dynamic> data;
  final String id;
  const UserCardCubitState(this.data, this.id);
}

class UserCardCubitStateInit extends UserCardCubitState {
  UserCardCubitStateInit() : super({}, "");
}

class UserCardCubitStateReady extends UserCardCubitState {
  const UserCardCubitStateReady(data, id) : super(data, id);
}

class UserCardCubitStateError extends UserCardCubitState {
  final String error;
  const UserCardCubitStateError(this.error, data, id) : super(data, id);
}
