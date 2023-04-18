import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import '../../app/data_source.dart';

class ChosenUserCubit extends Cubit<ChosenUserCubitState> {
  final DataSource ds;

  ChosenUserCubit(this.ds) : super(ChosenUserCubitStateInit());

  Future<void> choseUser(String id) async {
    if (state.id == id) return;
    emit(ChosenUserCubitStateLoading());

    final Map<String, dynamic> jsonData = await ds.getData(id, "users");

    try {
      emit(ChosenUserCubitStateReady(jsonData, id));
    } catch (e) {
      emit(ChosenUserCubitStateError(e.toString(), jsonData, id));
    }
  }

  Future<void> updateUserData(String id, String key, String value) async {
    await ds.updateData(
        id, state.data["json"], key, value); // async method, but use without await for react ui changing

    // final Map<String, dynamic> newData = state.data;
    // newData["json"][key] = value;

    // emit(ChosenUserCubitStateReady(newData, id));
  }
}

@immutable
abstract class ChosenUserCubitState {
  final Map<String, dynamic> data;
  final String id;
  const ChosenUserCubitState(this.data, this.id);
}

class ChosenUserCubitStateInit extends ChosenUserCubitState {
  ChosenUserCubitStateInit() : super({}, "");
}

class ChosenUserCubitStateLoading extends ChosenUserCubitState {
  ChosenUserCubitStateLoading() : super({}, "");
}

class ChosenUserCubitStateReady extends ChosenUserCubitState {
  const ChosenUserCubitStateReady(data, id) : super(data, id);
}

class ChosenUserCubitStateError extends ChosenUserCubitState {
  final String error;
  const ChosenUserCubitStateError(this.error, data, id) : super(data, id);
}
