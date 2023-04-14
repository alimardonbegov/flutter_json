import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../app/data_source.dart';
import './user_card_cubit.dart';
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
          return Column(
            children: [
              UserCardWidget(),
              Container(height: 2, color: Colors.black),
              Expanded(
                child: GridView.count(
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
                        .toList()),
              ),
            ],
          );
        } else if (state is ChosenUserCubitStateError) {
          return Container(child: Text(state.error));
        }
        return Container();
      },
    );
  }
}

class UserCardWidget extends StatelessWidget {
  // final ds = Modular.get<DataSource>();

  @override
  Widget build(BuildContext context) {
    final chosenUserCubit = BlocProvider.of<ChosenUserCubit>(context);

    return BlocProvider(
        create: (_) => UserCardCubit(chosenUserCubit),
        child: BlocBuilder<UserCardCubit, UserCardCubitState>(
          builder: (context, state) {
            if (state is UserCardCubitStateInit) {
              return const SizedBox(
                height: 250,
                child: Text("user not selected"),
              );
            } else if (state is UserCardCubitStateLoading) {
              return const SizedBox(
                height: 250,
                child: CircularProgressIndicator(),
              );
            } else if (state is UserCardCubitStateReady) {
              return Column(
                children: [
                  SizedBox(
                    height: 250,
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text(
                                    "${state.data["js3on"]["CLIENT_IME"] ?? "{name}"} ${[
                                          "CLIENT_PREZIME"
                                        ] ?? "{surname}"}",
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: const Text(
                                    '{company name}',
                                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                                  ),
                                  leading: const Icon(
                                    Icons.photo_camera_front_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                                const Divider(),
                                const ListTile(
                                  title: Text(
                                    '{detail information editable}',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              const ListTile(title: Icon(Icons.telegram, color: Colors.blue)),
                              const ListTile(title: Icon(Icons.facebook, color: Colors.blue)),
                              ListTile(
                                title: Text('${["CLIENT_PHONE"] ?? ""}'),
                                leading: const Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                ),
                              ),
                              ListTile(
                                title: Text('${["CLIENT_EMAIL"] ?? ""}'),
                                leading: const Icon(
                                  Icons.email,
                                  color: Colors.blue,
                                ),
                              ),
                              ListTile(
                                title: Text('${["CLIENT_LOCATION"] ?? ""}'),
                                leading: const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            } else if (state is UserCardCubitStateError) {
              return Container(child: Text(state.error));
            }
            return Container();
          },
        ));
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
