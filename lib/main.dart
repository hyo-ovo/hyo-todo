import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'providers/todo_provider.dart';
import 'models/todo.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HYO TODO',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: const Color(0xFFFFF9E5),
        fontFamily: 'Arial',
      ),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  TodoPageState createState() => TodoPageState();
}

class TodoPageState extends ConsumerState<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  String _currentDateTime = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentDateTime = _getCurrentDateTime();
    });
  }

  String _getCurrentDateTime() {
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = now.month.toString().padLeft(2, '0');
    String day = now.day.toString().padLeft(2, '0');
    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');
    return "$year-$month-$day $hour:$minute";
  }

  void _addTodo() {
    ref.read(todoProvider.notifier).addTodo(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoProvider);
    final doneCount = ref.watch(doneCountProvider);
    final totalCount = ref.watch(totalCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9E5),
      body: SafeArea(
        child: Column(
          children: [
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE066),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "HYO TODO",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentDateTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB59F3B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "완료: $doneCount / $totalCount",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFFB59F3B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "할 일을 입력하세요",
                        filled: true,
                        fillColor: const Color(0xFFFFFBEA), 
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (value) => _addTodo(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _addTodo,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFFFFE066), 
                      child: const Icon(Icons.add, color: Color(0xFFB59F3B)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: todos.isEmpty
                  ? const Center(
                      child: Text(
                        '할 일을 추가해보세요!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFB59F3B),
                        ),
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: todos.length,
                      onReorder: (oldIndex, newIndex) {
                        ref.read(todoProvider.notifier).reorderTodos(oldIndex, newIndex);
                      },
                      buildDefaultDragHandles: false,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return Card(
                          key: ValueKey(todo.id),
                          color: const Color(0xFFFFFBEA),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            isThreeLine: false,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: todo.done,
                                  onChanged: (_) => ref.read(todoProvider.notifier).toggleTodo(todo.id),
                                  activeColor: const Color(0xFFFFE066),
                                  checkColor: const Color(0xFFB59F3B),
                                ),
                              ],
                            ),
                            title: Text(
                              todo.task,
                              style: TextStyle(
                                decoration: todo.done
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.done
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              "생성: ${todo.created}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFFB59F3B)),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.drag_handle,
                                      color: const Color(0xFFB59F3B),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color(0xFFF7B801)),
                                  onPressed: () => ref.read(todoProvider.notifier).deleteTodo(todo.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
