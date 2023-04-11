import 'package:flutter/material.dart';

class UserBriefWidget extends StatelessWidget {
  const UserBriefWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: const <Widget>[
          Card(
            child: ListTile(
              leading: Icon(Icons.photo),
              title: Text('{name} {surname}'),
              subtitle: Text('{company name}'),
            ),
          )
        ],
      ),
    );
  }
}
