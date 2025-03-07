import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

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
  const PlanManagerScreen({super.key});

  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      plans.add(Plan(name: name, description: description, date: date, priority: priority));
      _sortPlansByPriority();
    });
  }

  void _sortPlansByPriority() {
    plans.sort((a, b) {
      const priorityOrder = {'High': 3, 'Medium': 2, 'Low': 1};
      return priorityOrder[b.priority]! - priorityOrder[a.priority]!;
    });
  }

  void _markCompleted(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _editPlan(int index, String name, String description, DateTime date, String priority) {
    setState(() {
      plans[index] = Plan(name: name, description: description, date: date, priority: priority);
      _sortPlansByPriority();
    });
  }

  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        String description = '';
        DateTime selectedDate = DateTime.now();
        String priority = 'Medium';

        return AlertDialog(
          title: Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Plan Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
              DropdownButton<String>(
                value: priority,
                items: ['Low', 'Medium', 'High']
                    .map((level) => DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => priority = value!),
              ),
              ElevatedButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() => selectedDate = pickedDate);
                  }
                },
                child: Text('Select Date'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addPlan(name, description, selectedDate, priority);
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }


void _showEditPlanDialog(int index, Plan plan) {
  TextEditingController nameController = TextEditingController(text: plan.name);
  TextEditingController descriptionController = TextEditingController(text: plan.description);
  DateTime selectedDate = plan.date;
  String priority = plan.priority;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Plan Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              value: priority,
              items: ['Low', 'Medium', 'High']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    priority = value;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text('Select Date'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _editPlan(index, nameController.text, descriptionController.text, selectedDate, priority);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adoption & Travel Plans')),
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: plans.isEmpty
            ? ElevatedButton(
                onPressed: _showCreatePlanDialog,
                child: Text('Start Planning'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showCreatePlanDialog,
                    child: Text('Add Another Plan'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        // Format the date
                        String formattedDate = DateFormat('MM/dd/yyyy').format(plan.date);

                        return Dismissible(
                          key: Key(plan.name),
                          background: Container(color: Colors.green),
                          secondaryBackground: Container(color: Colors.red),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.startToEnd) {
                              _markCompleted(index);
                            } else {
                              _deletePlan(index);
                            }
                            setState(() {
                              plans.removeAt(index);
                            });
                          },
                          child: GestureDetector(
                            onDoubleTap: () {
                              // Remove the plan when double-tapped
                              _deletePlan(index);
                            },
                            child: ListTile(
                              tileColor: plan.isCompleted ? Colors.green[100] : Colors.yellow[100], // Color-coded based on completion
                              title: Text(
                                plan.name,
                                style: TextStyle(
                                  decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${plan.description} - ${plan.priority}'),
                                  Text('Due: $formattedDate', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                                ],
                              ),
                              onLongPress: () => _showEditPlanDialog(index, plan),
                              trailing: IconButton(
                                icon: Icon(
                                  plan.isCompleted ? Icons.check_circle:  Icons.radio_button_unchecked,
                                  color: plan.isCompleted ? Colors.green : Colors.grey,
                                ),
                                onPressed: () => _markCompleted(index), // Toggle completion status
                              ),
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
