import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import '../app/DataSource.dart';

class ChosenUserCubit extends Cubit<ChosenUserCubitState> {
  final DataSource ds;

  ChosenUserCubit(this.ds) : super(ChosenUserCubitStateInit());

  Future<void> choseUser(String id) async {
    if (state.id == id) return;
    emit(ChosenUserCubitStateLoading());
    final Map<String, dynamic> jsonData = await ds.readData(id, "users");
    final Map<String, dynamic> jsonItem = jsonData["json"];
    try {
      emit(ChosenUserCubitStateReady(jsonItem, id));
    } catch (e) {
      emit(ChosenUserCubitStateError(e.toString(), jsonItem, id));
    }
  }

  Future<void> updateUserData(String id, String key, String value) async {
    await ds.updateData(id, state.data, key, value);
  }
}

@immutable
abstract class ChosenUserCubitState {
  final Map<String, dynamic> data;
  final String id;
  ChosenUserCubitState(this.data, this.id);
}

class ChosenUserCubitStateInit extends ChosenUserCubitState {
  ChosenUserCubitStateInit() : super({}, "");
}

class ChosenUserCubitStateLoading extends ChosenUserCubitState {
  ChosenUserCubitStateLoading() : super({}, "");
}

class ChosenUserCubitStateReady extends ChosenUserCubitState {
  ChosenUserCubitStateReady(data, id) : super(data, id);
}

class ChosenUserCubitStateError extends ChosenUserCubitState {
  final String error;
  ChosenUserCubitStateError(this.error, data, id) : super(data, id);
}
