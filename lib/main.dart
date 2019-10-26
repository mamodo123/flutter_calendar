import 'package:flutter/material.dart';

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
                Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(width: 1, color: Colors.black)),
                  child: Calendar(
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
                    minimumDate: DateTime.parse("2019-10-13"),
                    maximumDate: DateTime.parse("2019-11-22"),
                    events: [
                      DateTime.parse("2019-10-26"),
                      DateTime.parse("2019-10-26"),
                      DateTime.parse("2019-10-25")
                    ],
                    onSelectedDay: (day) {
                      setState(() {
                        text = day.toIso8601String();
                      });
                    },
                  ),
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

class Calendar extends StatefulWidget {
  static const DAYS_OF_WEEK = {
    DateTime.monday: "Monday",
    DateTime.tuesday: "Tuesday",
    DateTime.wednesday: "Wednesday",
    DateTime.thursday: "Thursday",
    DateTime.friday: "Friday",
    DateTime.saturday: "Saturday",
    DateTime.sunday: "Sunday"
  };

  static const MONTHS_OF_YEAR = {
    DateTime.january: "January",
    DateTime.february: "February",
    DateTime.march: "March",
    DateTime.april: "April",
    DateTime.may: "May",
    DateTime.june: "June",
    DateTime.july: "July",
    DateTime.august: "August",
    DateTime.september: "September",
    DateTime.october: "October",
    DateTime.november: "November",
    DateTime.december: "December",
  };

  Map<int, String> nameDaysOfWeek, nameMonthsOfYear;
  List<int> disabledDays;
  DateTime firstSelected, maximumDate, minimumDate;
  Function(DateTime day) onSelectedDay;
  Map<int, int> events;
  Color disabledDayColor;
  Color selectedDayColor;
  Color normalDayColor;
  Color outOfRangeDayColor;
  bool showDivider;

  //in implementation
  bool showMonth = true;

  Calendar(
      {Map<int, String> nameDaysOfWeek,
      Map<int, String> nameMonthsOfYear,
      DateTime firstSelected,
      DateTime maximumDate,
      DateTime minimumDate,
      List<DateTime> events,
      this.disabledDays = const [],
      this.onSelectedDay,
      this.disabledDayColor = Colors.red,
      this.selectedDayColor = Colors.blue,
      this.normalDayColor = Colors.black,
      this.outOfRangeDayColor = Colors.grey,
      this.showDivider = true,
      /*this.showMonth = true*/}) {
    if (maximumDate != null && minimumDate != null) {
      assert(!minimumDate.isAfter(maximumDate),
          "Minimum date can't be after the Maximum date.");
    }
    assert(disabledDays.length < 7,
        "Disabled days has to be lesser than 7, or you can't select a day.");

    final tempDate = firstSelected != null ? firstSelected : DateTime.now();
    this.firstSelected = _zeroHour(tempDate);

    if (maximumDate != null) {
      this.maximumDate = _zeroHour(maximumDate);
      if (this.firstSelected.isAfter(maximumDate)) {
        var willBeFirstSelected = maximumDate;
        while (disabledDays.contains(willBeFirstSelected.weekday)) {
          willBeFirstSelected = willBeFirstSelected.add(Duration(days: -1));
        }
        this.firstSelected = willBeFirstSelected;
      }
    }

    if (minimumDate != null) {
      this.minimumDate = _zeroHour(minimumDate);
      if (this.firstSelected.isBefore(minimumDate)) {
        var willBeFirstSelected = minimumDate;
        while (disabledDays.contains(willBeFirstSelected.weekday)) {
          willBeFirstSelected = willBeFirstSelected.add(Duration(days: 1));
        }
        this.firstSelected = willBeFirstSelected;
      }
    }

    if (nameDaysOfWeek != null) {
      var nameDaysOfWeekTemp = Map<int, String>.from(DAYS_OF_WEEK);
      nameDaysOfWeek.keys.forEach((i) {
        nameDaysOfWeekTemp[i] = nameDaysOfWeek[i];
      });
      this.nameDaysOfWeek = nameDaysOfWeekTemp;
    } else {
      this.nameDaysOfWeek = DAYS_OF_WEEK;
    }

    if (nameMonthsOfYear != null) {
      var nameMonthsOfYearTemp = Map<int, String>.from(MONTHS_OF_YEAR);
      nameMonthsOfYear.keys.forEach((i) {
        nameMonthsOfYearTemp[i] = nameMonthsOfYear[i];
      });
      this.nameMonthsOfYear = nameMonthsOfYearTemp;
    } else {
      this.nameMonthsOfYear = MONTHS_OF_YEAR;
    }

    this.events = Map();
    events?.forEach((date) {
      final zeroHour = _zeroHour(date);
      this.events[zeroHour.millisecondsSinceEpoch] =
          (this.events[zeroHour.millisecondsSinceEpoch] ?? 0) + 1;
    });
  }

  @override
  _CalendarState createState() => _CalendarState(firstSelected);
}

class _CalendarState extends State<Calendar> {
  List<DateTime> week;
  DateTime selected;
  DateTime showing;

  _CalendarState(DateTime firstSelected) {
    this.week = generateWeek(firstSelected);
    this.selected = firstSelected;
    this.showing = firstSelected;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          widget.showMonth? Row(
            children: <Widget>[
              _greaterThanMinimum(week.first)
                  ? FlatButton(
                      child: Text("<"),
                      onPressed: () {
                        showing = showing.add(Duration(days: -7));
                        setState(() {
                          week = generateWeek(showing);
                        });
                      },
                    )
                  : FlatButton(
                      onPressed: null,
                      child: Container(),
                    ),
              Expanded(
                  child: Center(
                      child: Text(widget.nameMonthsOfYear[week.last.month] +
                          " " +
                          week.last.year.toString(), style: TextStyle(fontSize: 18),))),
              _lesserThanMaximum(week.last)
                  ? FlatButton(
                      child: Text(">"),
                      onPressed: () {
                        showing = showing.add(Duration(days: 7));
                        setState(() {
                          week = generateWeek(showing);
                        });
                      },
                    )
                  : FlatButton(
                      onPressed: null,
                      child: Container(),
                    ),
            ],
          ) : Container(),
          !widget.showMonth || !widget.showDivider ? Container() : Divider(thickness: 1, color: Colors.black, height: 3,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: week.map((day) {
              return GestureDetector(
                onTap: () {
                  if (_isOkDay(day)) {
                    setState(() {
                      this.selected = day;
                    });
                    widget.onSelectedDay(day);
                  }
                },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: <Widget>[
                    Text(
                      (widget.events[_zeroHour(day).millisecondsSinceEpoch] ??
                              "")
                          .toString(),
                      style: TextStyle(color: _getDayColor(day), fontSize: 10),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: <Widget>[
                          Text(
                            widget.nameDaysOfWeek[day.weekday].substring(0, 3),
                            style: TextStyle(
                                fontSize: 15, color: _getDayColor(day),
                            decoration: _isSameDay(day, DateTime.now()) ? TextDecoration.underline : null),
                          ),
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                                fontSize: 12, color: _getDayColor(day)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<DateTime> generateWeek(DateTime dayOfTheWeek) {
    final day = dayOfTheWeek.weekday - 1;
    return List.generate(7, (i) {
      return dayOfTheWeek.add(Duration(days: i - day));
    });
  }

  Color _getDayColor(DateTime day) {
    /*if (_isSameDay(day, DateTime.now())) {
      return Colors.green;
    } else */if ((widget.minimumDate != null &&
            day.isBefore(widget.minimumDate)) ||
        (widget.maximumDate != null && day.isAfter(widget.maximumDate))) {
      return widget.outOfRangeDayColor;
    } else if (widget.disabledDays.contains(day.weekday)) {
      return widget.disabledDayColor;
    } else if (_isSameDay(selected, day)) {
      return widget.selectedDayColor;
    } else {
      return widget.normalDayColor;
    }
  }

  bool _greaterThanMinimum(DateTime date) {
    if (widget.minimumDate == null) {
      return true;
    } else {
      if (date.isAfter(widget.minimumDate)) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool _lesserThanMaximum(DateTime date) {
    if (widget.maximumDate == null) {
      return true;
    } else {
      if (date.isBefore(widget.maximumDate)) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool _isOkDay(DateTime day) {
    return !((widget.minimumDate != null && day.isBefore(widget.minimumDate)) ||
        (widget.maximumDate != null && day.isAfter(widget.maximumDate)) ||
        widget.disabledDays.contains(day.weekday));
  }
}

bool _isSameDay(DateTime time1, DateTime time2) {
  return time1.year == time2.year &&
      time1.month == time2.month &&
      time1.day == time2.day;
}

DateTime _zeroHour(DateTime date) {
  return DateTime(date.year, date.month, date.day, 0, 0, 0, 0, 0);
}
