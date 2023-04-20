import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import './data/user_data_cubit.dart';
import './card/card.dart';

class UserDetail extends StatelessWidget {
  const UserDetail({super.key});

  @override
  Widget build(BuildContext context) {
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
                    ElevatedButton(onPressed: () => Modular.to.navigate('/customer_data'), child: const Text('Data')),
                    ElevatedButton(
                        onPressed: () => Modular.to.navigate('/customer_documents'), child: const Text('Documents')),
                  ],
                ),
              ),
              Container(height: 2, color: Colors.black),
              const Expanded(child: RouterOutlet()),
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
