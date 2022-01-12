// @dart=2.9

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/components/componets.dart';
import 'package:todo_app/components/cubit/cubit.dart';
import 'package:todo_app/components/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var titleConroller = TextEditingController();
  var timeConroller = TextEditingController();
  var dateConroller = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(title: Text(cubit.Title[cubit.currentindex])),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.Screens[cubit.currentindex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomsheetshown) {
                  if (formKey.currentState.validate()) {
                    cubit.insetToDatabase(
                        title: titleConroller.text,
                        date: dateConroller.text,
                        time: timeConroller.text);
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet(
                        (context) => Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaulyFormField(
                                    prefixicon: Icons.title,
                                    controller: titleConroller,
                                    keyboardtype: TextInputType.text,
                                    labelText: "Task title",
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Title must not be empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  defaulyFormField(
                                    onTap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeConroller.text =
                                            value.format(context);
                                      });
                                    },
                                    prefixicon: Icons.watch_later_outlined,
                                    controller: timeConroller,
                                    keyboardtype: TextInputType.datetime,
                                    labelText: "Task time",
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Time must not be empty";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  defaulyFormField(
                                    onTap: () {
                                      showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate:
                                                  DateTime.parse('2026-11-20'))
                                          .then((value) {
                                        dateConroller.text =
                                            DateFormat.yMMMd().format(value);
                                      });
                                    },
                                    prefixicon: Icons.calendar_today,
                                    controller: dateConroller,
                                    keyboardtype: TextInputType.datetime,
                                    labelText: "Date time",
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Date must not be empty";
                                      }
                                      return null;
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetShown(false, Icons.edit);
                  });

                  cubit.changeBottomSheetShown(true, Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.currentindex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: "Tasks",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: "Done",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: "Archive",
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
