import 'package:flutter/material.dart';

import 'calendar.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var text = "waiting";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Calendar',
        home: SafeArea(
            child: Scaffold(
          appBar: AppBar(
            title: Text("Flutter Calendar"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Calendar(
                  nameDaysOfWeek: {
                    DateTime.monday: "Segunda",
                    DateTime.tuesday: "Terça",
                    DateTime.wednesday: "Quarta",
                    DateTime.thursday: "Quinta",
                    DateTime.friday: "Sexta",
                    DateTime.saturday: "Sábado",
                    DateTime.sunday: "Domingo"
                  },
                  nameMonthsOfYear: {
                    DateTime.january: "Janeiro",
                    DateTime.february: "Fevereiro",
                    DateTime.march: "Março",
                    DateTime.april: "Abril",
                    DateTime.may: "Maio",
                    DateTime.june: "Junho",
                    DateTime.july: "Julho",
                    DateTime.august: "Agosto",
                    DateTime.september: "Setembro",
                    DateTime.october: "Outubro",
                    DateTime.november: "Novembro",
                    DateTime.december: "Dezembro",
                  },
                  disabledDays: [DateTime.saturday, DateTime.sunday],
                  minimumDate: DateTime.now(),
                  maximumDate: DateTime.now().add(Duration(days: 14)),
                  events: [
                    DateTime.now().add(Duration(days: 1)),
                    DateTime.now().add(Duration(days: 1)),
                    DateTime.now().add(Duration(days: 2)),
                    DateTime.now().add(Duration(days: 3)),
                  ],
                  holidays: [
                    DateTime.now().add(Duration(days: 1)),
                    DateTime.now().add(Duration(days: 6)),
                    DateTime.now().add(Duration(days: 8)),
                    DateTime.now().add(Duration(days: 11))
                  ],
                  onSelectedDay: (day) {
                    setState(() {
                      text = day.toIso8601String();
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(text),
                  ),
                )
              ],
            ),
          ),
        )));
  }
}