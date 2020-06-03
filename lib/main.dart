import 'package:flutter/material.dart';
import 'login.dart';

//void main() => runApp(LoginPage());
void main() => runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'OOTW',
      home: LoginPage(),
    );

  }

}