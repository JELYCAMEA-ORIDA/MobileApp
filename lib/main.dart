import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOBILE APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 252, 81, 95)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'MOBILE APP'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentPage()),
                );
              },
              child: Text('Students'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoursePage()),
                );
              },
              child: Text('Courses'),
            ),
          ],
        ),
      ),
    );
  }
}

class StudentPage extends StatefulWidget {
  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  List<dynamic> students = [];
  static const String apiUrl = 'http://localhost:5000'; // Add http:// prefix
  bool isLoading = true; // Define isLoading variable

  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _courseIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final Uri url = Uri.parse('$apiUrl/students/'); // Use Uri.parse for full URL

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is List<dynamic>) {
          setState(() {
            students = body;
            isLoading = false; // Hide the loading indicator
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<void> addStudent() async {
    final studentId = int.tryParse(_studentIdController.text);
    final studentName = _studentNameController.text;
    final courseId = int.tryParse(_courseIdController.text);

    if (studentId == null || studentName.isEmpty || courseId == null) {
      print('All fields are required');
      return;
    }

    final Uri url = Uri.parse('$apiUrl/addstudents');
    final Map<String, String> requestBody = {
      'student_id': _studentIdController.text,
      'student_name': _studentNameController.text,
      'course_id': _courseIdController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Student added successfully');
        // Refresh student list
        await fetchStudents();
        // Clear text fields
        _studentIdController.clear();
        _studentNameController.clear();
        _courseIdController.clear();
      } else {
        print('Failed to add student. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> updateStudent() async {
    final studentId = int.tryParse(_studentIdController.text);
    final studentName = _studentNameController.text;
    final courseId = int.tryParse(_courseIdController.text);

    if (studentId == null || studentName.isEmpty || courseId == null) {
      print('All fields are required');
      return;
    }

    final Uri url = Uri.parse('$apiUrl/student/edit/${_studentIdController.text}');
    final Map<String, String> requestBody = {
      'student_name': studentName,
      'course_id': courseId.toString(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Student updated successfully');
        // Refresh student list
        await fetchStudents();
        // Clear text fields
        _studentIdController.clear();
        _studentNameController.clear();
        _courseIdController.clear();
      } else {
        print('Failed to update student. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteStudent(int studentId) async {
    final Uri url = Uri.parse('$apiUrl/students/delete/$studentId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print('Student deleted successfully');
        await fetchStudents(); // Refresh student list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student deleted successfully'),
          ),
        );
      } else {
        throw Exception('Failed to delete student: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting student: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _studentIdController,
              decoration: InputDecoration(labelText: 'Student ID'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _studentNameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _courseIdController,
              decoration: InputDecoration(labelText: 'Course ID'),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await addStudent(); // Call addStudent function
                    },
                    child: Text('Add'),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add logic to handle updating student
                      updateStudent();
                    },
                    child: Text('Update'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Student List',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 10),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (students.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('Student ID')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Course ID')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      students.length,
                      (index) => DataRow(
                        cells: [
                          DataCell(Text('${students[index]['student_id']}')),
                          DataCell(Text('${students[index]['student_name']}')),
                          DataCell(Text('${students[index]['course_id']}')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  deleteStudent(students[index]['student_id']);
                                },
                                icon: Icon(Icons.delete),
                                color: Color.fromARGB(255, 252, 122, 165),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _studentIdController.text = students[index]['student_id'].toString();
                                    _studentNameController.text = students[index]['student_name'];
                                    _courseIdController.text = students[index]['course_id'].toString();
                                  });
                                },
                                icon: Icon(Icons.edit),
                                color: Color.fromARGB(255, 103, 130, 248),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text('No students found'),
              ),
          ],
        ),
      ),
    );
  }
}








class CoursePage extends StatefulWidget {
  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  final TextEditingController _courseIdController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  List<dynamic> courses = [];
  static const String apiUrl = 'http://localhost:5000'; // Include the protocol
  bool isLoading = true;


  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final Uri url = Uri.parse('$apiUrl/courses/');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is List<dynamic>) {
          setState(() {
            courses = body;
            isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load courses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  void showAddSuccessSnackBar() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Course added successfully'),
      duration: Duration(seconds: 2), // Adjust duration as needed
    ),
  );
}

Future<void> addCourse() async {
  final courseId = int.tryParse(_courseIdController.text);
  final courseName = _courseNameController.text;

  if (courseId == null || courseName.isEmpty) {
    print('All fields are required');
    return;
  }

  final Uri url = Uri.http('localhost:5000', '/addcourses'); // Adjusted URL path
  final Map<String, String> requestBody = {
    'course_id': courseId.toString(), // Convert course ID to string
    'course_name': courseName,
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Course added successfully');
      // Show SnackBar for successful course addition
      showAddSuccessSnackBar();
      // Refresh course list
      await fetchCourses();
      // Clear text fields
      _courseIdController.clear();
      _courseNameController.clear();
    } else {
      print('Failed to add course. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

void showDeleteSuccessSnackBar() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Course deleted successfully'),
      duration: Duration(seconds: 2), // Adjust duration as needed
    ),
  );
}

Future<void> deleteCourse(int courseId) async {
  try {
    final Uri url = Uri.parse('$apiUrl/deletecourse/$courseId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      print('Course deleted successfully');
      setState(() {
        courses.removeWhere((course) => course['course_id'] == courseId);
      });
      showDeleteSuccessSnackBar(); // Show SnackBar when course is deleted successfully
    } else {
      throw Exception('Failed to delete course: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting course: $e');
  }
}


void showUpdateSuccessSnackBar() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Course updated successfully'),
      duration: Duration(seconds: 2), // Adjust duration as needed
    ),
  );
}

Future<void> updateCourse() async {
  final courseId = int.tryParse(_courseIdController.text);
  final courseName = _courseNameController.text;

  if (courseId == null || courseName.isEmpty) {
    print('All fields are required');
    return;
  }

  final Uri url = Uri.parse('$apiUrl/editcourse/$courseId');
  final Map<String, String> requestBody = {
    'course_name': courseName,
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('Course updated successfully');
      // Show SnackBar for successful course update
      showUpdateSuccessSnackBar();
      // Refresh course list
      await fetchCourses();
      // Clear text fields
      _courseIdController.clear();
      _courseNameController.clear();
    } else {
      print('Failed to update course. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                'Course List',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _courseIdController,
                    decoration: InputDecoration(labelText: 'Course ID'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _courseNameController,
                    decoration: InputDecoration(labelText: 'Course Name'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await addCourse();
                    },
                    child: Text('Add'),
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      updateCourse();
                    },
                    child: Text('Update'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (courses.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: <DataColumn>[
                      DataColumn(label: Text('Course ID')),
                      DataColumn(label: Text('Course Name')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List<DataRow>.generate(
                      courses.length,
                      (index) => DataRow(
                        cells: [
                          DataCell(Text('${courses[index]['course_id']}')),
                          DataCell(Text('${courses[index]['course_name']}')),
                          DataCell(Row(
                            children: [
                                      IconButton(
                                        onPressed: () {
                                          deleteCourse(courses[index]['course_id']);
                                        },
                                        icon: Icon(Icons.delete),
                                        color: Color.fromARGB(255, 252, 122, 165),
                                      ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _courseIdController.text = courses[index]['course_id'].toString();
                                              _courseNameController.text = courses[index]['course_name'];
                                            });
                                          },
                                          icon: Icon(Icons.edit),
                                          color: Color.fromARGB(255, 103, 130, 248),
                                        ),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Text('No courses found'),
              ),
          ],
        ),
      ),
    );
  }
}