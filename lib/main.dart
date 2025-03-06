import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  String priority;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    required this.priority,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  
  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date, priority: priority));
      _sortPlans();
    });
  }

  void _editPlan(int index, String newName, String newDescription, DateTime newDate, String newPriority) {
    setState(() {
      plans[index].name = newName;
      plans[index].description = newDescription;
      plans[index].date = newDate;
      plans[index].priority = newPriority;
      _sortPlans();
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _sortPlans() {
    setState(() {
      plans.sort((a, b) {
        const priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
        return priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!);
      });
    });
  }

  void _showPlanDialog({int? index}) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedPriority = 'Medium';

    if (index != null) {
      nameController.text = plans[index].name;
      descController.text = plans[index].description;
      selectedDate = plans[index].date;
      selectedPriority = plans[index].priority;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == null ? 'Create Plan' : 'Edit Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Plan Name')),
            TextField(controller: descController, decoration: InputDecoration(labelText: 'Description')),
            DropdownButton<String>(
              value: selectedPriority,
              items: ['Low', 'Medium', 'High'].map((priority) {
                return DropdownMenuItem(value: priority, child: Text(priority));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedPriority = value;
                }
              },
            ),
            ElevatedButton(
              child: Text('Select Date'),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() => selectedDate = pickedDate);
                }
              },
            )
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (index == null) {
                _addPlan(nameController.text, descController.text, selectedDate, selectedPriority);
              } else {
                _editPlan(index, nameController.text, descController.text, selectedDate, selectedPriority);
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager')),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Dismissible(
            key: Key(plan.name),
            background: Container(color: Colors.green, alignment: Alignment.centerLeft, child: Icon(Icons.check, color: Colors.white)),
            secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, child: Icon(Icons.delete, color: Colors.white)),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                _toggleCompletion(index);
              }else{
              () => _deletePlan(index);
              }
            },
            child: ListTile(
              title: Text(plan.name, style: TextStyle(decoration: plan.isCompleted ? TextDecoration.lineThrough : null)),
              subtitle: Text('${plan.description}\n${plan.date.toLocal()}'.split(' ')[0]),
              trailing: Text(plan.priority, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              onLongPress: () => _showPlanDialog(index: index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showPlanDialog(),
      ),
    );
  }
}

