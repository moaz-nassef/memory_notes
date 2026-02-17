import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class TaskModel {

  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  TaskModel({
    required this.title,
    this.isDone = false,
  });
}
