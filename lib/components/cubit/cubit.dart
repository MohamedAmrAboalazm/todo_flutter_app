// @dart=2.9

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/components/cubit/states.dart';
import 'package:todo_app/modules/archive_tasks.dart';
import 'package:todo_app/modules/done_tasks.dart';
import 'package:todo_app/modules/new_tasks.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitalState());

  static AppCubit get(context) => BlocProvider.of(context);
  Database database;
  int currentindex = 0;
  bool isBottomsheetshown = false;
  IconData fabIcon = Icons.edit;
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  List<Widget> Screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivesScreen(),
  ];
  List<String> Title = ['new', 'done', 'archived'];
  void changeIndex(int index) {
    currentindex = index;
    emit(AppChangeBottomNavBarState());
  }

  void changeBottomSheetShown(@required bool isShow, @required IconData icon) {
    isBottomsheetshown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }

  void createDataBase() {
    openDatabase(
      "Todo.db",
      version: 1,
      onCreate: (database, version) {
        print('Database created');
        database
            .execute(
                'CREATE TABLE tasks(id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((erorr) {
          print('Erorr when creating table${erorr.toString()}');
        });
      },
      onOpen: (database) {
        getDataFromDatabase(database);
        print('Database opened');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insetToDatabase({
    @required String title,
    @required String date,
    @required String time,
  }) {
    database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date","$time","new")')
          .then((value) {
        print("$value inserted successfully");
        emit(AppInsertDatabaseState());
        getDataFromDatabase(database);
      }).catchError((erorr) {
        print('Erorr when inserting table${erorr.toString()}');
      });
      return null;
    });
  }

  updateData({
    @required String status,
    @required int id,
  }) {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  deleteData(@required int id) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }

  void getDataFromDatabase(database) {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    emit(AppGetDatabaseLoadingState());
    database.rawQuery("SELECT * FROM tasks").then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }
}
