import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../user_data/user_data_cubit.dart';
import './user_card_cubit.dart';

class UserCardWidget extends StatelessWidget {
  const UserCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chosenUserCubit = BlocProvider.of<ChosenUserCubit>(context);

    // return BlocListener(
    //   listener: (context, state) {
    //     print("$state");
    //   },
    //   bloc: BlocProvider.of<UserCardCubit>(context),
    //   child: const SizedBox(
    //     height: 100,
    //     child: Text("card cubit"),
    //   ),
    // );

    return BlocBuilder<UserCardCubit, UserCardCubitState>(
      bloc: UserCardCubit(chosenUserCubit),
      builder: (context, state) {
        if (state is UserCardCubitStateInit) {
          return const SizedBox(
            height: 250,
            child: Text("user not selected"),
          );
        }
        // else if (state is UserCardCubitStateLoading) {
        //   return const SizedBox(
        //     height: 250,
        //     child: CircularProgressIndicator(),
        //   );
        // }
        else if (state is UserCardCubitStateReady) {
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
                                "${state.data["js3on"]["CLIENT_IME"] ?? "{name}"} ${["CLIENT_PREZIME"] ?? "{surname}"}",
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
    );
  }
}
