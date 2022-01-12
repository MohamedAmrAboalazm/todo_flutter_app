import 'package:bloc/bloc.dart';
import 'components/bloc_observer.dart';
import 'layouts/todo_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(FlutterApp());
}

class FlutterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeLayout(),
    );
  }
}
