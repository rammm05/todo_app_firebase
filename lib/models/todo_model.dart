class TodoModel {
  String? todoId;
  String title;
  String desc;
  bool isCompleted;
  int priority; // 3 -> low(blue) , 2 -> medium(orange) , 1 -> high(red)
  String assignedAt;
  String completedAt;


  TodoModel({
    required this.title,
    required this.desc,
    this.isCompleted = false,
    this.priority = 1,
    required this.assignedAt,
    this.completedAt = "",
    this.todoId
});

//from doc to model
factory TodoModel.fromDoc({required Map<String, dynamic> doc}){
  return TodoModel(
    todoId: doc["todoId"],
      title: doc["title"],
      desc: doc["desc"],
      isCompleted: doc["isCompleted"],
      priority: doc["priority"],
      assignedAt: doc["assignedAt"],
      completedAt: doc["completedAt"],
  );
}

// to doc
Map<String, dynamic> toDoc(){
  return {
    "title" : title,
    "desc" : desc,
    "isCompleted" : isCompleted,
    "priority" : priority,
    "assignedAt" : assignedAt,
    "completedAt" : completedAt,
  };
}

}