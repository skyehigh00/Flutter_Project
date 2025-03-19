import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ToDoList(),
    BackgroundChanger(),
    AudioPlayerWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Bunineng"),
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'To-Do'),
            BottomNavigationBarItem(icon: Icon(Icons.color_lens), label: 'Background'),
            BottomNavigationBarItem(icon: Icon(Icons.audiotrack), label: 'Audio'),
          ],
        ),
      ),
    );
  }
}

class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();
  DateTime? selectedDueDate;

  void _pickDueDate(BuildContext context, Function(DateTime) onDateSelected) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      onDateSelected(pickedDate);
    }
  }

  void _addTask() {
    if (taskController.text.isNotEmpty && selectedDueDate != null) {
      setState(() {
        tasks.add({
          "task": taskController.text,
          "completed": false,
          "dueDate": DateFormat.yMMMd().format(selectedDueDate!),
        });
        taskController.clear();
        selectedDueDate = null;
      });
    }
  }

  void _editTask(int index) {
    TextEditingController editController = TextEditingController(text: tasks[index]["task"]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: "Task"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  tasks[index]["task"] = editController.text;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _editDueDate(int index) {
    _pickDueDate(context, (pickedDate) {
      setState(() {
        tasks[index]["dueDate"] = DateFormat.yMMMd().format(pickedDate);
      });
    });
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: "Enter task",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _pickDueDate(context, (date) {
                      setState(() {
                        selectedDueDate = date;
                      });
                    }),
                    child: Text(selectedDueDate == null ? "Pick Due Date" : DateFormat.yMMMd().format(selectedDueDate!)),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addTask,
                    child: Text("Add Task"),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? Center(child: Text("No tasks available. Add one!"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(tasks[index]["task"],
                            style: TextStyle(
                                decoration: tasks[index]["completed"]
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none)),
                        subtitle: Text("Due: ${tasks[index]["dueDate"]}"),
                        leading: Checkbox(
                          value: tasks[index]["completed"],
                          onChanged: (bool? value) {
                            setState(() {
                              tasks[index]["completed"] = value ?? false;
                            });
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.date_range, color: Colors.blue),
                              onPressed: () => _editDueDate(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editTask(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


class BackgroundChanger extends StatefulWidget {
  @override
  _BackgroundChangerState createState() => _BackgroundChangerState();
}

class _BackgroundChangerState extends State<BackgroundChanger> {
  Color _backgroundColor = Colors.white;
  double _startX = 0;

  void _changeBackground(bool isSwipeLeft) {
    setState(() {
      _backgroundColor = isSwipeLeft ? const Color.fromARGB(255, 255, 0, 238) : const Color.fromARGB(255, 255, 115, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _startX = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (details) {
        double delta = details.globalPosition.dx - _startX;
        if (delta < -50) {
          _changeBackground(true);
        } else if (delta > 50) {
          _changeBackground(false);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: _backgroundColor,
        alignment: Alignment.center,
        child: Text("Swipe left or right to change background", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}


class AudioPlayerWidget extends StatefulWidget {
  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  void _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource('audio/Aya.mp3'));
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Now Playing", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 220,
            color: Colors.grey[900],
            child: Icon(Icons.music_video, size: 120, color: Colors.redAccent),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Aya - Earl Agustin", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Artist Name", style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          Slider(
            min: 0,
            max: _duration.inSeconds.toDouble(),
            value: _position.inSeconds.toDouble(),
            activeColor: Colors.redAccent,
            onChanged: (value) async {
              await _audioPlayer.seek(Duration(seconds: value.toInt()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}", style: TextStyle(color: Colors.white)),
                Text("${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, size: 40, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  size: 60,
                  color: Colors.redAccent,
                ),
                onPressed: _playPause,
              ),
              IconButton(
                icon: Icon(Icons.skip_next, size: 40, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Colors.white24),
          ListTile(
            leading: Icon(Icons.queue_music, color: Colors.white),
            title: Text("Up Next", style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ),
        ],
      ),
    );
  }
}