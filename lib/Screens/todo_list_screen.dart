import 'package:flutter/material.dart';
import 'package:to_do_app/Screens/add_task_screen.dart';
import 'package:to_do_app/helpers/database_helpers.dart';
import 'package:to_do_app/models/task_models.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Future<List<Task>> _tasksList;

  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    print('updateTaskList called');
    setState(() {
      _tasksList = DatabaseHelper.instance.getTaskList();
    });
    print(_tasksList.toString());
  }
  String giveTime(TimeOfDay time){
    String hour= time.hour > 12 ? '${time.hour - 12}' : '${time.hour}';
    String minute = '${time.minute}';
    String phase = time.hour > 12 ? 'PM' : 'AM';

    return hour+':'+minute+" "+phase;

  }

  Widget _buildTask(Task task) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                fontSize: 18,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(
              '${task.date.toString().substring(0, 10)} at ${giveTime(task.time)} ~ ${task.priority}',
              style: TextStyle(
                fontSize: 15,
                decoration: task.status == 0
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
            trailing: Checkbox(
              onChanged: (value) {
                print(value);
                task.status = task.status == 0 ? 1 : 0;
                DatabaseHelper.instance.updateTask(task);
                _updateTaskList();
              },
              activeColor: Colors.blue,
              value: task.status == 1,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTaskScreen(
                  task: task,
                  updateTaskList: _updateTaskList,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black54,
            thickness: 0.6,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[600],
        title: Text(
          'To Do',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[400],
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTaskScreen(
                updateTaskList: _updateTaskList,
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _tasksList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedtaskCount = snapshot.data
              .where((Task task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            itemCount: 1 + snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tasks',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      ' $completedtaskCount of ${snapshot.data.length} Completed',
                      style: TextStyle(color: Colors.brown[200], fontSize: 20),
                    ),
                  ],
                );
              }
              return _buildTask(snapshot.data[index - 1]);
            },
          );
        },
      ),
    );
  }
}
