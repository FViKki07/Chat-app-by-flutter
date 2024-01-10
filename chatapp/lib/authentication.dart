import 'package:flutter/material.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  AuthenticationFormState createState() {
    return AuthenticationFormState();
  }
}

class AuthenticationFormState extends State<Authentication> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: const Column(
          children: <Widget>[
      Align(
      alignment: AlignmentDirectional(-1, -1),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
        child: Text(
          'Никнейм'
          ),
        ),
      ),
      // Add TextFormFields and ElevatedButton here.
      ],
    ),);
  }

}