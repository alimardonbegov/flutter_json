import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../app/templater.dart';
import '../app/data_source.dart';
import './cubit.dart';

class HomePage extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text("Json")),
        body: BlocProvider(
          create: (_) => ChosenUserCubit(ds),
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

/// left part of screen - rendering list of users

class UsersListWidget extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  Future<bool> getUsers() async {
    await ds.getInitData("selectInit");

    // ! TEMPLATOR
    // String tplId = "xwshzdift79mk6n";
    // String tplPath = "assets/templates/tpl.docx";
    // String companyId = "f6tt406qe0fu7q2";

    // final templater = Templater(ds);

    // final List<int> bytes = await templater.generateDoc(tplId, companyId);
    // final String linkToDoc = await templater.uploadDocToDB(companyId, bytes);

    // print(linkToDoc);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ds = Modular.get<DataSource>();
    final cubit = BlocProvider.of<ChosenUserCubit>(context);

    return FutureBuilder(
      future: getUsers(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: ds.usersList.length,
            itemBuilder: (context, index) {
              var item = ds.usersList[index];
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(item.getStringValue("username")),
                subtitle: Text(item.getStringValue("email")),
                onTap: () => cubit.choseUser(item.id),
              );
            },
          );
        } else if (snapshot.hasError) {
          print("snapshot error: ${snapshot.error}");
          return const Text("Something went wrong");
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

/// right part of screen - rendering list of user's field (from config_user)

class ConfigInputsWidget extends StatelessWidget {
  final ds = Modular.get<DataSource>();

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
                children: ds.config.entries
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

/// input rendering from config_user

class InputWidget extends StatelessWidget {
  final String initValue;
  final String id;
  final String keyMap;
  final Map<String, List<String>> config;
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
            labelText: config["eng"]![0],
            hintText: config["eng"]![1],
          ),
          controller: _controller,
        ),
        onFocusChange: (hasFocus) {
          if (hasFocus) return;
          onStopEditing(id, keyMap, _controller.text);
        });
  }
}
