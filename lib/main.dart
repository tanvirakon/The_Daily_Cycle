import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:yoo/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int mealCount = 0;
  int costOfOneMeal = 0;
  int _counter = 0;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  Map<DateTime, int> mealOnDates = {};

  @override
  void initState() {
    super.initState();
    getOneMealCost();
    getMealMap();
    getTotalMealNumbers();
  }

  //cost of one meal save
  Future<void> saveOneMealCost(int variable) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('oneMealCost', variable);
  }

  Future<void> getOneMealCost() async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt('oneMealCost') ?? 0;
    setState(() {
      costOfOneMeal = counter;
      //print('costOfoneMeal $costOfOneMeal');
    });
  }

  //number of total meals -> save
  Future<void> saveTotalMealNumbers(int counter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalMealNumbers', counter);
  }

  Future<void> getTotalMealNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt('totalMealNumbers') ?? 0;
    setState(() {
      mealCount = counter;
      _counter += mealCount;
    });
  }

  //mealOnDates map store as string using json
  Future<void> saveMealMap(Map mapOfMeals) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert datetime keys to strings
    Map<String, int> convertedMap = {};
    mapOfMeals.forEach((key, value) {
      convertedMap[key.toString()] = value;
    });

    String encodedMap = json.encode(convertedMap);

    prefs.setString('mealMap', encodedMap);
  }

  Future<void> getMealMap() async {
    final prefs = await SharedPreferences.getInstance();
    String? counter = prefs.getString('mealMap');

    //string to map

    // Decode the JSON string
    Map<String, dynamic> decodedMap = json.decode(counter!);

    // Create a new map to store the converted values
    Map<DateTime, int> mapOfMeals = {};

    // Convert the keys from strings to DateTime objects and add them to the new map
    decodedMap.forEach((key, value) {
      DateTime dateTimeKey = DateTime.parse(key);
      mapOfMeals[dateTimeKey] = value;
    });

    setState(() {
      mealOnDates = mapOfMeals;
    });
  }

  mealcost() {
    int sum = 0;
    mealOnDates.keys.forEach((value) {
      if (value.month == DateTime.now().month) {
        sum += mealOnDates[value]!;
      }
    });
    mealCount = sum;
  }

  final _controller = TextEditingController();
  final _controllerMealRate = TextEditingController();

  Future _incrementCounter(DateTime date) async => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(
              "Edit meal numbers",
              textAlign: TextAlign.center,
            ),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Input Number',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => _controller.clear(),
                  ),
                  hintText: _controller.text,
                  labelStyle: TextStyle(color: Colors.black)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "cancel",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Color(0xffcd73128)),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_controller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Cant be empty!!"),
                      duration: Duration(seconds: 1),
                    ));
                  } else {
                    DateTime anydate = date;
                    DateTime anydateSpecific =
                        DateTime(anydate.year, anydate.month, anydate.day);
                    setState(() {
                      // new value asle ager ta delete
                      if (mealOnDates[anydateSpecific] != null)
                        mealOnDates.remove(anydateSpecific);
                      mealOnDates[anydateSpecific] =
                          int.parse(_controller.text);
                      Navigator.pop(context);
                    });
                  }
                  setState(() {
                    mealcost();
                    //print('mealcount in okay setState $mealCount');
                    saveTotalMealNumbers(mealCount);
                    _counter = mealCount;
                    //print(mealOnDates);
                    saveMealMap(mealOnDates);
                  });
                },
                child: Text(
                  "Okay",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Color(0xffcd73128)),
                ),
              )
            ],
          ));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffcd73128),
          title: Text("The Daily Cycle"),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          ],
        ),
        body: Column(
          children: [
            SizedBox(height: 19),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: TextField(
                    controller: _controllerMealRate,
                    decoration: InputDecoration(
                      hintText: 'How much does one meal cost?! ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(7),
                  alignment: Alignment.center,
                  color: Color(0xffcd73128),
                  child: TextButton(
                      onPressed: () {
                        costOfOneMeal = int.parse(_controllerMealRate.text);
                        setState(() {
                          saveOneMealCost(costOfOneMeal);
                        });
                      },
                      child: Text(
                        "Okay",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ),
              ],
            ),
            SizedBox(height: 19),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    padding: EdgeInsets.all(15),
                    alignment: Alignment.centerLeft,
                    color: Color(0xffcd73128),
                    child: Text(
                      "Cost this month ${_counter * costOfOneMeal} tk",
                      style: TextStyle(color: Colors.white),
                      textScaleFactor: 2,
                      textAlign: TextAlign.left,
                    )),
                SizedBox(
                  width: 9,
                ),
                Container(
                  padding: EdgeInsets.all(7),
                  alignment: Alignment.center,
                  color: Color(0xffcd73128),
                  child: TextButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text(
                                      "This will delete everything. Are you sure?"),
                                  actions: [
                                    TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Color(0xffcd73128))),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "No",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                    TextButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Color(0xffcd73128))),
                                        onPressed: () {
                                          mealOnDates.clear();
                                          Navigator.pop(context);
                                          setState(() {
                                            mealCount = 0;
                                            _counter = 0;
                                            mealOnDates = {};
                                            saveTotalMealNumbers(mealCount);
                                            saveMealMap(mealOnDates);
                                          });
                                        },
                                        child: Text(
                                          "Yes",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ],
                                ));
                      },
                      child: Text(
                        "Clear",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                )
              ],
            ),
            SizedBox(height: 19),
            Container(
              child: TableCalendar(
                  calendarStyle: CalendarStyle(
                    cellMargin: EdgeInsets.all(8),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFFFF800B),
                            Color(0xFFCE1010),
                          ]),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ),

                  //any day focus
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  rowHeight: 40,
                  daysOfWeekHeight: 50,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  availableGestures: AvailableGestures.all,
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2022),
                  lastDay: DateTime.utc(2024, 4, 25)),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Color(0xffcd73128),
          onPressed: () => _incrementCounter(_selectedDay),
          label: Text("Add"),
          icon: Icon(Icons.add),
        ),
      ),
    );
  }
}