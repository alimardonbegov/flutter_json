import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../app/data_source.dart';
import './user_data_cubit.dart';

class UserDataWidget extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  UserDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ChosenUserCubit>(context);

    return BlocBuilder<ChosenUserCubit, ChosenUserCubitState>(
      builder: (context, state) {
        if (state is ChosenUserCubitStateInit) {
          return Center(
            child: Row(
              children: const [
                Icon(Icons.arrow_back),
                Text("Select user"),
              ],
            ),
          );
        } else if (state is ChosenUserCubitStateLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChosenUserCubitStateReady) {
          return GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 8,
              children: ds.config.entries
                  .map((entrie) => InputWidget(
                        initValue: state.data["json"][entrie.key] ?? "",
                        config: entrie.value,
                        onStopEditing: cubit.updateUserData,
                        id: state.id,
                        keyMap: entrie.key,
                      ))
                  .toList());
        } else if (state is ChosenUserCubitStateError) {
          return Text(state.error);
        }
        return Container();
      },
    );
  }
}

/// input rendering from config_user

class InputWidget extends StatelessWidget {
  final String initValue;
  final String id;
  final String keyMap;
  final Map<String, List<String>> config;
  final Function onStopEditing;
  final _controller = TextEditingController();

  InputWidget({
    super.key,
    required this.initValue,
    required this.config,
    required this.onStopEditing,
    required this.id,
    required this.keyMap,
  }) {
    _controller.text = initValue ?? "";
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: config["eng"]![0],
            hintText: config["eng"]![1],
            border: const OutlineInputBorder(),
          ),
          controller: _controller,
        ),
        onFocusChange: (hasFocus) {
          if (hasFocus) return;
          onStopEditing(id, keyMap, _controller.text);
        });
  }
}
