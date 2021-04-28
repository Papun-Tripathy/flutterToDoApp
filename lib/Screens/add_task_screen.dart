import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_app/helpers/database_helpers.dart';
import 'package:to_do_app/models/task_models.dart';
import 'package:to_do_app/services/notification.dart';

class AddTaskScreen extends StatefulWidget {
  final Task task;
  final Function updateTaskList;
  AddTaskScreen({this.updateTaskList, this.task});
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formkey = GlobalKey<FormState>();
  String _title = '';
  String _priority = 'Low';
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeControler = TextEditingController();
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  // final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');

  _handleDatePicker() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _date.toString().substring(0, 10);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task.id);
    widget.updateTaskList();
    Navigator.pop(context);
  }

  _submit() {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      print('$_title, $_priority, ${_date.toString().runtimeType}');

      // insert the task to the user database
      Task task =
          Task(title: _title, date: _date, priority: _priority, time: _time);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task.id;
        task.status = widget.task.status;
        DatabaseHelper.instance.updateTask(task);
      }
      print('insertion done');
      // update the task
      widget.updateTaskList();

      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    Provider.of<NotificationService>(context, listen: false).initialize();
    if (widget.task != null) {
      _title = widget.task.title;
      _date = widget.task.date;
      _priority = widget.task.priority;
    }
    _dateController.text = _date.toString().substring(0, 10);
    _timeControler.text = giveTime(_time);
  }

  String giveTime(TimeOfDay time) {
    String hour = time.hour > 12 ? '${time.hour - 12}' : '${time.hour}';
    String minute = '${time.minute}';
    String phase = time.hour > 12 ? 'PM' : 'AM';

    return hour + ':' + minute + " " + phase;
  }

  void _selectTime() async {
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (newTime != null && newTime != TimeOfDay.now()) {
      setState(() {
        _time = newTime;
      });
      _timeControler.text = giveTime(_time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'Add Task' : 'Update Task',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => value.trim().isEmpty
                            ? 'Please enter a valid input'
                            : null,
                        onSaved: (input) => _title = input,
                        initialValue: _title,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: _handleDatePicker,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: _timeControler,
                        readOnly: true,
                        onTap: _selectTime,
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      DropdownButtonFormField(
                        icon: Icon(Icons.arrow_drop_down_circle_outlined),
                        iconSize: 21,
                        isDense: true,
                        iconEnabledColor: Colors.blue[800],
                        items: _priorities.map((String e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(
                              e,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: TextStyle(fontSize: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => _priority == null
                            ? 'Please select a valid Priority'
                            : null,
                        onSaved: (input) => _priority = input,
                        onChanged: (value) {
                          setState(() {
                            _priority = value;
                          });
                        },
                        value: _priority,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue[400],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            widget.task == null ? 'Add' : 'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      widget.task != null
                          ? Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.blue[400],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                onPressed: _delete,
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
