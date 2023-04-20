import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../data/user_data_cubit.dart';

class CustomerDataCubit extends Cubit<CustomerDataCubitState> {
  final ChosenUserCubit chosenUserCubit;
  late StreamSubscription<ChosenUserCubitState> _sub;

  CustomerDataCubit(this.chosenUserCubit)
      : super(CustomerDataCubitStateInit(chosenUserCubit.state.data, chosenUserCubit.state.id)) {
    _sub = chosenUserCubit.stream.listen((state) {
      if (state is ChosenUserCubitStateReady) {
        emit(CustomerDataCubitStateUpdated(state.data, state.id));
      } else if (state is ChosenUserCubitStateError) {
        emit(CustomerDataCubitStateError(state.error, state.data, state.id));
      }
    });
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}

@immutable
abstract class CustomerDataCubitState {
  final Map<String, dynamic> data;
  final String id;
  const CustomerDataCubitState(this.data, this.id);
}

class CustomerDataCubitStateInit extends CustomerDataCubitState {
  const CustomerDataCubitStateInit(data, id) : super(data, id);
}

class CustomerDataCubitStateUpdated extends CustomerDataCubitState {
  const CustomerDataCubitStateUpdated(data, id) : super(data, id);
}

class CustomerDataCubitStateError extends CustomerDataCubitState {
  final String error;
  const CustomerDataCubitStateError(this.error, data, id) : super(data, id);
}
