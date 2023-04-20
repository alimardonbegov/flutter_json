import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../app/data_source.dart';
import 'data/user_data_cubit.dart';
import 'user_detail.dart';
import './users_list.dart';

class HomePage extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Json")),
      body: BlocProvider(
        create: (_) => ChosenUserCubit(ds),
        child: Row(
          children: [
            SizedBox(width: 400, child: UsersListWidget()),
            Container(width: 2, color: Colors.black),
            const Expanded(child: UserDetail()),
          ],
        ),
      ),
      // )
    );
  }
}
