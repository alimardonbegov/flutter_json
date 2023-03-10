import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_js/app/TplFacade.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:http/http.dart' as http;
import '../app/DataSource.dart';
import './cubit.dart';

class HomePage extends StatelessWidget {
  final dataSource = Modular.get<DataSource>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Json")),
        body: BlocProvider(
          create: (_) => ChosenUserCubit(dataSource),
          child: Row(
            children: <Widget>[
              Expanded(child: UsersListWidget()),
              Container(width: 2, color: Colors.black),
              Expanded(child: ConfigInputsWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class UsersListWidget extends StatelessWidget {
  final dataSource = Modular.get<DataSource>();
  final tplFacade = Modular.get<TplFacade>();

  Future<bool> getUsers() async {
    await dataSource.getInitData("select");

    String tplId = "2sylungy3q251b9";
    String companyId = "bf2ckhikimw8b34";

    await tplFacade.generateDocumentFromRemoteTpl(tplId, companyId);
    // await tplFacade.uploadDocumentToPb();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<ChosenUserCubit>(context);
    return FutureBuilder(
      future: getUsers(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: dataSource.usersList.length,
            itemBuilder: (context, index) {
              var item = dataSource.usersList[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(item.getStringValue("username")),
                subtitle: Text(item.getStringValue("email")),
                onTap: () => cubit.choseUser(item.id),
              );
            },
          );
        } else if (snapshot.hasError) {
          return const Text("Something went wrong");
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ConfigInputsWidget extends StatelessWidget {
  final dataSource = Modular.get<DataSource>();

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
          return SingleChildScrollView(
            child: Column(
                children: dataSource.config.entries
                    .map((entrie) => InputWidget(
                          initValue: state.data[entrie.key] ?? "",
                          config: entrie.value,
                          onStopEditing: cubit.updateUserData,
                          id: state.id,
                          keyMap: entrie.key,
                        ))
                    .toList()),
          );
        } else if (state is ChosenUserCubitStateError) {
          return Container(child: Text(state.error));
        }
        return Container();
      },
    );
  }
}

class InputWidget extends StatelessWidget {
  final String initValue;
  final String id;
  final String keyMap;
  final Map<String, String> config;
  final Function onStopEditing;
  final TextEditingController _controller = TextEditingController();

  InputWidget({
    super.key,
    required this.initValue,
    required this.config,
    required this.onStopEditing,
    required this.id,
    required this.keyMap,
  }) {
    _controller.text = initValue ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: config["title"],
            hintText: config["hint"],
          ),
          controller: _controller,
        ),
        onFocusChange: (hasFocus) {
          if (hasFocus) return;
          onStopEditing(id, keyMap, _controller.text);
        });
  }
}
