class Todo {
  final String id;
  final String task;
  final bool done;
  final String created;

  Todo({
    required this.id,
    required this.task,
    required this.done,
    required this.created,
  });

  Todo copyWith({
    String? id,
    String? task,
    bool? done,
    String? created,
  }) {
    return Todo(
      id: id ?? this.id,
      task: task ?? this.task,
      done: done ?? this.done,
      created: created ?? this.created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task': task,
      'done': done,
      'created': created,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] ?? '',
      task: map['task'] ?? '',
      done: map['done'] ?? false,
      created: map['created'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Todo(id: $id, task: $task, done: $done, created: $created)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
