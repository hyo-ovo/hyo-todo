import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

class TodoNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return [];
  }

  void addTodo(String task) {
    if (task.trim().isEmpty) return;
    
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      task: task.trim(),
      done: false,
      created: _getCurrentDateTime(),
    );
    
    state = [...state, todo];
  }

  void toggleTodo(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        final updatedTodo = todo.copyWith(done: !todo.done);
        return updatedTodo;
      }
      return todo;
    }).toList();
    
    final completedTodos = state.where((todo) => todo.done).toList();
    final pendingTodos = state.where((todo) => !todo.done).toList();
    state = [...pendingTodos, ...completedTodos];
  }

  void deleteTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void reorderTodos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    if (oldIndex == newIndex) return;
    
    final List<Todo> newList = List.from(state);
    final Todo item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    state = newList;
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
}

final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

final doneCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider);
  return todos.where((todo) => todo.done).length;
});

final totalCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoProvider);
  return todos.length;
});
