import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/app_widgets/my_outlined_custom_btn.dart';
import 'package:todo_app/firebase_repo/firebase_repository.dart';
import 'package:todo_app/models/todo_model.dart';
import 'package:todo_app/utils/util_helper.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{
  List<TodoModel> listTodo = [];
  var titleController = TextEditingController();
  var descController = TextEditingController();
  List<String> listPriority = ["High", "Medium", "Low"];
  String selectedPriority = "High";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: "ToDo",
            style: mTextStyle25(),
            children: [
              TextSpan(
                text: " Manager",
                style: mTextStyle25(
                  mColor: Colors.blue,
                  mFontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseRepository.fetchAllTodo(),
            builder: (_, snapshot){

              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator());
              }

              if(snapshot.hasError){
                return Center(child: Text(snapshot.error.toString()));
              }

              if(snapshot.hasData){

                listTodo.clear();
                for(QueryDocumentSnapshot<Map<String, dynamic>> eachDoc in snapshot.data!.docs){
                  listTodo.add(TodoModel.fromDoc(doc: eachDoc.data()));

                }

                return listTodo.isNotEmpty
                    ? ListView.builder(
                  itemCount: listTodo.length,
                  itemBuilder: (_, index) {

                    DateFormat df = DateFormat.yMMMd().add_jm();
                    //DateFormat tf = DateFormat.Hms();

                    String assignedTime = df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(listTodo[index].assignedAt)));
                    var completedTime = listTodo[index].completedAt != "" ? df.format(DateTime.fromMillisecondsSinceEpoch(int.parse(listTodo[index].completedAt))) : "";

                    return InkWell(
                      onTap: (){
                        showModalBottomSheet(context: context, builder: (context){
                          return bottomSheetContent(context: context, isUpdate: true, index: index);
                        });
                      },
                      child: Card(
                        color: getBackgroundColor(listTodo[index].priority),
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Checkbox(
                                checkColor: Colors.white,
                                value: listTodo[index].isCompleted,
                                onChanged: (value) {
                                  FirebaseRepository.markTodoStatus(listTodo[index].todoId!, value!);
                                },),
                              title: Text(listTodo[index].title, style: mTextStyle16(mColor: Colors.white).copyWith(
                                  decoration: listTodo[index].isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness: 5,
                                decorationColor: Colors.white

                              ),),
                              subtitle: Text(listTodo[index].desc, style: mTextStyle12(mColor: Colors.white).copyWith(
                                  decoration: listTodo[index].isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness: 3,
                                  decorationColor: Colors.white

                              ),),
                              trailing: IconButton(onPressed: (){
                                FirebaseRepository.deleteTodo(todoId: listTodo[index].todoId!);
                              }, icon: Icon(CupertinoIcons.delete, size: 20,)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 11),
                              child: Row(
                                children: [
                                  RichText(text:
                                  TextSpan(
                                      text: "Assigned at: ",
                                    style: mTextStyle12(mColor: Colors.white, mFontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                          text: assignedTime,
                                      style: mTextStyle12(mColor: Colors.white,))]
                                  )
                                  )
                                ],
                              ),
                            ),
                            completedTime != ""
                                ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 11),
                              child: Row(
                                children: [
                                  RichText(text:
                                  TextSpan(
                                      text: "Completed at: ",
                                      style: mTextStyle12(mColor: Colors.white,
                                          mFontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                            text: completedTime,
                                            style: mTextStyle12(
                                              mColor: Colors.white,))
                                      ]
                                  )
                                  )
                                ],
                              ),
                            )
                                : Container(),
                          ],
                        ),
                      ),
                    );
                  },
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No Todo's yet",
                        style: mTextStyle16(mColor: Colors.grey.shade400),
                      ),
                      SizedBox(height: 2),
                      MyOutlinedCustomBtn(
                        title: "Add now +",
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) {
                              return bottomSheetContent(context: context);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              return Container();

            })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return bottomSheetContent(context: context);
            },
          );
        },
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        splashColor: Colors.blue,
        elevation: 11,
        child: Icon(Icons.add),
      ),
    );
  }

  Color getBackgroundColor(int priority){
    if(priority == 3){
      return Colors.blue;
    } else if(priority == 2){
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget bottomSheetContent({
    required BuildContext context,
    bool isUpdate = false,
    int index = -1
  }) {
    titleController.clear();
    descController.clear();

    if(isUpdate){
      titleController.text = listTodo[index].title;
      descController.text = listTodo[index].desc;
      selectedPriority = listPriority[listTodo[index].priority-1];
    } else {
      selectedPriority = "High";
    }


    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 11,
          top: 11,
          bottom: 11 + MediaQuery.of(context).viewInsets.bottom,
        ),
        height:
        MediaQuery.of(context).size.height * 0.5 +
            MediaQuery.of(context).viewInsets.bottom,
        width: double.infinity,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.back,
                    color: Colors.blue,
                    size: 16,
                  ),
                ),
                SizedBox(width: 5),
                Text(isUpdate ? "Update ToDO" : "Add ToDo",
                  style: mTextStyle16(
                    mFontWeight: FontWeight.bold,
                    mColor: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 21),
            TextField(
              controller: titleController,
              style: mTextStyle16(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                label: Text(isUpdate ? "Updated Title" :'Title', style: mTextStyle16(mColor: Colors.blue)),
                hintText: isUpdate ? "Enter updated title here" :'Enter title here',
                hintStyle: mTextStyle16(mColor: Colors.grey),
              ),
            ),
            SizedBox(height: 11),
            TextField(
              controller: descController,
              style: mTextStyle16(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Colors.blue),
                ),
                label: Text(isUpdate ? "Updated Desc" : 'Desc', style: mTextStyle16(mColor: Colors.blue)),
                hintText: isUpdate ? "Enter updated desc here" :'Enter desc here',
                hintStyle: mTextStyle16(mColor: Colors.grey),
              ),
            ),
            SizedBox(height: 11),
            DropdownMenu(
              onSelected: (value){
                selectedPriority = value!;
              },
              width: MediaQuery.of(context).size.width - 22,
              textStyle: mTextStyle16(mColor: Colors.blue),
              selectedTrailingIcon: Icon(Icons.low_priority_outlined),
              label: Text('Priority', style: mTextStyle16(mColor: Colors.blue)),
              trailingIcon: Icon(
                Icons.arrow_drop_down_circle_rounded,
                color: Colors.blue,
              ),
              initialSelection: isUpdate ? listPriority[listTodo[index].priority-1] : null,

              dropdownMenuEntries: listPriority
                  .map(
                    (priority) => DropdownMenuEntry(
                  value: priority,
                  label: priority,
                  style: ButtonStyle(
                    textStyle: WidgetStateTextStyle.resolveWith(
                          (states) => mTextStyle12(),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),


            SizedBox(height: 11),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyOutlinedCustomBtn(title: isUpdate ? "Update" :"Add", onPressed: () {

                  //add the Todo
                  var todoModel = TodoModel(
                    title: titleController.text,
                    desc: descController.text,
                    priority: selectedPriority == "High" ? 1 : selectedPriority == "Medium" ? 2 : 3,
                    assignedAt: DateTime.now().millisecondsSinceEpoch.toString(),

                  );

                  if(isUpdate){
                    FirebaseRepository.updateTodo(
                        todoId: listTodo[index].todoId!,
                        updatedTitle: titleController.text,
                        updatedDesc: descController.text,
                        priority: selectedPriority == "High" ? 1 : selectedPriority == "Medium" ? 2 : 3,
                        assignedAt: DateTime.now().millisecondsSinceEpoch.toString()
                    );
                  } else {
                    FirebaseRepository.addTodo(todoModel);
                  }

                  Navigator.pop(context);

                }),
                MyOutlinedCustomBtn(
                  title: "Cancel",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
