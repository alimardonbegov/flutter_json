import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../data/user_data_cubit.dart';

class CustomerDataBloc extends Bloc<CustomerDataEvent, CustomerDataBlocState> {
  final ChosenUserCubit chosenUserCubit;
  late StreamSubscription<ChosenUserCubitState> _chosenUserCubitSubscription;

  CustomerDataBloc(this.chosenUserCubit)
      : super(CustomerDataBlocStateInit(chosenUserCubit.state.data, chosenUserCubit.state.id)) {
    on<CustomerDataEvent>((event, emit) {
      if (event is CustomerDataChanged) {
        emit(CustomerDataBlocStateUpdated(event.data, event.id));
      }
    });

    // переписать на события без подпискиб либо вынести подписку за пределы блока

    // _chosenUserCubitSubscription = chosenUserCubit.stream.listen((state) {
    //   if (state is ChosenUserCubitStateReady) {
    //     emit(CustomerDataBlocStateUpdated(state.data, state.id));
    //   } else if (state is ChosenUserCubitStateError) {
    //     emit(CustomerDataBlocStateError(state.error, state.data, state.id));
    //   }
    // });
  }

  @override
  Future<void> close() {
    _chosenUserCubitSubscription.cancel();
    return super.close();
  }
}

@immutable
abstract class CustomerDataEvent {}

class CustomerDataChanged extends CustomerDataEvent {
  final Map<String, dynamic> data;
  final String id;
  CustomerDataChanged(this.data, this.id);
}

@immutable
abstract class CustomerDataBlocState {
  final Map<String, dynamic> data;
  final String id;
  const CustomerDataBlocState(this.data, this.id);
}

class CustomerDataBlocStateInit extends CustomerDataBlocState {
  const CustomerDataBlocStateInit(data, id) : super(data, id);
}

class CustomerDataBlocStateUpdated extends CustomerDataBlocState {
  const CustomerDataBlocStateUpdated(data, id) : super(data, id);
}

class CustomerDataBlocStateError extends CustomerDataBlocState {
  final String error;
  const CustomerDataBlocStateError(this.error, data, id) : super(data, id);
}
