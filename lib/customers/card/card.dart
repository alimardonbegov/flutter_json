import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_js/customers/card/card_cubit.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../app/data_source.dart';
import '../data/user_data_cubit.dart';
import './card_bloc.dart';

class UserCardWidget extends StatelessWidget {
  final ds = Modular.get<DataSource>();

  UserCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final chosenUserCubit = BlocProvider.of<ChosenUserCubit>(context);
    // final cardBloc = BlocProvider.of<CustomerDataBloc>(context);

    return BlocProvider(
      create: (_) => CustomerDataCubit(chosenUserCubit),
      child: BlocBuilder<CustomerDataCubit, CustomerDataCubitState>(
        builder: (context, state) {
          if (state is CustomerDataCubitStateInit || state is CustomerDataCubitStateUpdated) {
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
                                  "${state.data["json"]["CLIENT_IME"] ?? "{name}"} ${state.data["json"]["CLIENT_PREZIME"] ?? "{surname}"}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  "${state.data["json"]["COMPANY_NAME"] ?? "{company name}"}",
                                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
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
                              title: Text('${state.data["json"]["CLIENT_PHONE"] ?? "{client phone}"}'),
                              leading: const Icon(
                                Icons.phone,
                                color: Colors.blue,
                              ),
                            ),
                            ListTile(
                              title: Text('${state.data["json"]["CLIENT_EMAIL"] ?? "{client email}"}'),
                              leading: const Icon(
                                Icons.email,
                                color: Colors.blue,
                              ),
                            ),
                            ListTile(
                              title: Text('${state.data["json"]["CLIENT_LOCATION"] ?? "{client location}"}'),
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
          }
          // else if (state is CustomerDataBlocStateError) {
          //   return Container(child: Text(state.error));
          // }
          return Container();
        },
      ),
    );
  }
}
