import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import './user_data_cubit.dart';

class UserCardCubit extends Cubit<UserCardCubitState> {
  // UserCardCubit() : super(UserCardCubitStateInit());

  // void changeData(data, id) {
  //   emit(UserCardCubitStateReady(data, id));
  // }

  // !first example (not chaning state)
  final ChosenUserCubit chosenUserCubit;
  late StreamSubscription<ChosenUserCubitState> userCardSubscription;

  UserCardCubit(
    this.chosenUserCubit,
  ) : super(UserCardCubitStateInit()) {
    userCardSubscription = chosenUserCubit.stream.listen((ChosenUserCubitState chosenUserState) {
      if (chosenUserState is ChosenUserCubitStateLoading) {
        emit(UserCardCubitStateLoading());
      }

      if (chosenUserState is ChosenUserCubitStateReady) {
        emit(UserCardCubitStateReady(chosenUserState.data, chosenUserState.id));
      }

      if (chosenUserState is ChosenUserCubitStateError) {
        emit(UserCardCubitStateError(chosenUserState.error, chosenUserState.data, chosenUserState.id));
      }
    });
  }

  // @override
  // void onChange(Cubit<UserCardCubitState> change) {
  //   print(change);
  //   super.onChange(change);
  // }

  // @override
  // Future<void> close() {
  //   userSubscription.cancel();
  //   return super.close();
  // }
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

class UserCardCubitStateLoading extends UserCardCubitState {
  UserCardCubitStateLoading() : super({}, "");
}

class UserCardCubitStateReady extends UserCardCubitState {
  const UserCardCubitStateReady(data, id) : super(data, id);
}

class UserCardCubitStateError extends UserCardCubitState {
  final String error;
  const UserCardCubitStateError(this.error, data, id) : super(data, id);
}
