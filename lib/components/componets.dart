// @dart=2.9

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cubit/cubit.dart';

Widget defaulyFormField(
    {@required IconData prefixicon,
    @required TextEditingController controller,
    @required TextInputType keyboardtype,
    IconData suffixicon,
    Function onTap,
    bool obscuretext = false,
    bool isClickable = true,
    @required String labelText,
    @required Function validator}) {
  return TextFormField(
    enabled: isClickable,
    onTap: onTap,
    controller: controller,
    keyboardType: keyboardtype,
    validator: validator,
    obscureText: obscuretext,
    decoration: InputDecoration(
      prefixIcon: Icon(prefixicon),
      suffixIcon: suffixicon != null ? Icon(suffixicon) : null,
      labelText: labelText,
      border: OutlineInputBorder(),
    ),
  );
}

Widget buildTaskItem({@required Map model, @required context}) {
  return Dismissible(
    key: Key(model['id'].toString()),
    onDismissed: (direction) {
      AppCubit.get(context).deleteData(model['id']);
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            child: Text("${model['time']}"),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${model['title']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text("${model['date']}", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context).updateData(status: "done", id: model['id']);
            },
            icon: Icon(Icons.check_box),
            color: Colors.green,
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {
              AppCubit.get(context)
                  .updateData(status: "archive", id: model['id']);
            },
            icon: Icon(Icons.archive),
            color: Colors.black54,
          ),
        ],
      ),
    ),
  );
}

Widget tasksBuilder(@required List<Map> tasks) => ConditionalBuilder(
      condition: tasks.length > 0,
      builder: (context) => ListView.separated(
          itemBuilder: (context, index) =>
              buildTaskItem(model: tasks[index], context: context),
          separatorBuilder: (context, index) => Container(
                width: double.infinity,
                height: 1,
                color: Colors.grey[300],
              ),
          itemCount: tasks.length),
      fallback: (context) => Center(
          child: Text(
        "No Tasks Yet, Please Add Some Tasks",
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
      )),
    );
