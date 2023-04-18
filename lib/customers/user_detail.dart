import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../app/data_source.dart';
import './user_data/user_data.dart';
import './user_data/user_data_cubit.dart';
import './user_card/user_card.dart';

class UserDetail extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  UserDetail({super.key});

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
              SizedBox(
                height: 20,
                child: Row(
                  children: [
                    ElevatedButton(onPressed: () => Modular.to.navigate('/page1'), child: Text('Page 1')),
                    ElevatedButton(onPressed: () => Modular.to.navigate('/page2'), child: Text('Page 2')),
                    ElevatedButton(onPressed: () => Modular.to.navigate('/page3'), child: Text('Page 3'))
                  ],
                ),
              ),

              Container(height: 2, color: Colors.black),
              Expanded(child: RouterOutlet()),
              // Expanded(child: UserDataWidget(ds: ds, cubit: cubit, state: state)),
            ],
          );
        } else if (state is ChosenUserCubitStateError) {
          return Text(state.error);
        }
        return Container();
      },
    );
  }
}
