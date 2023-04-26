import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

// import 'package:pdf_google_fonts/pdf_google_fonts.dart';

import '../app/data_source.dart';
import '../app/pdf_tpl.dart';
import '../app/docx_tpl.dart';
import './data/user_data_cubit.dart';

/// left part of the screen - rendering list of users

class UsersListWidget extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  Future<bool> getUsers() async {
    await ds.getInitData("selectInit");

    // ! TEMPLATOR for docx

    // final templater = Templater(ds);

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
                leading: const Icon(Icons.person),
                title: Text(item.getStringValue("username")),
                subtitle: Text(item.getStringValue("company")),
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
