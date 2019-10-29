import 'package:flutter/widgets.dart';

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
  List<int> holidays;
  Color disabledDayColor;
  Color selectedDayColor;
  Color normalDayColor;
  Color outOfRangeDayColor;
  bool showBorder;
  bool showDivider;

  //in implementation
  bool showMonth = true;

  //

  Calendar({
    Map<int, String> nameDaysOfWeek,
    Map<int, String> nameMonthsOfYear,
    DateTime firstSelected,
    DateTime maximumDate,
    DateTime minimumDate,
    List<DateTime> events,
    List<DateTime> holidays = const [],
    this.disabledDays = const [],
    this.onSelectedDay,
    this.disabledDayColor = Colors.red,
    this.selectedDayColor = Colors.blue,
    this.normalDayColor = Colors.black,
    this.outOfRangeDayColor = Colors.grey,
    this.showBorder = true,
    this.showDivider = true,
    /*this.showMonth = true*/
  }) {
    if (maximumDate != null && minimumDate != null) {
      assert(!minimumDate.isAfter(maximumDate),
      "Minimum date can't be after the Maximum date.");
    }

    if (firstSelected != null) {
      if (maximumDate != null) {
        assert(!firstSelected.isAfter(maximumDate),
        "First selected date can't be after the maximum date");
      }
      if (minimumDate != null) {
        assert(!minimumDate.isBefore(minimumDate),
        "First selected date can't be before the minimum date");
      }

      assert(!disabledDays.contains(firstSelected.weekday),
      "First selected date can't be a disabled day");
    }

    if (firstSelected != null) {
      this.firstSelected = _zeroHour(firstSelected);
    }
    if (minimumDate != null) {
      this.minimumDate = _zeroHour(minimumDate);
    }
    if (maximumDate != null) {
      this.maximumDate = _zeroHour(maximumDate);
    }

    _getDaysOfWeekName(nameDaysOfWeek);
    _getMonthsName(nameMonthsOfYear);
    _getEvents(events);
    _getHolidays(holidays);
  }

  @override
  _CalendarState createState() => _CalendarState(
    nameDaysOfWeek: nameDaysOfWeek,
    nameMonthsOfYear: nameMonthsOfYear,
    firstSelected: firstSelected,
    maximumDate: maximumDate,
    minimumDate: minimumDate,
    events: events,
    holidays: holidays,
    disabledDays: disabledDays,
    onSelectedDay: onSelectedDay,
    disabledDayColor: disabledDayColor,
    selectedDayColor: selectedDayColor,
    normalDayColor: normalDayColor,
    outOfRangeDayColor: outOfRangeDayColor,
    showBorder: showBorder,
    showDivider: showDivider,
  );

  _getDaysOfWeekName(Map<int, String> nameDaysOfWeek) {
    if (nameDaysOfWeek != null) {
      var nameDaysOfWeekTemp = Map<int, String>.from(DAYS_OF_WEEK);
      nameDaysOfWeek.keys.forEach((i) {
        nameDaysOfWeekTemp[i] = nameDaysOfWeek[i];
      });
      this.nameDaysOfWeek = nameDaysOfWeekTemp;
    } else {
      this.nameDaysOfWeek = DAYS_OF_WEEK;
    }
  }

  _getMonthsName(Map<int, String> nameMonthsOfYear) {
    if (nameMonthsOfYear != null) {
      var nameMonthsOfYearTemp = Map<int, String>.from(MONTHS_OF_YEAR);
      nameMonthsOfYear.keys.forEach((i) {
        nameMonthsOfYearTemp[i] = nameMonthsOfYear[i];
      });
      this.nameMonthsOfYear = nameMonthsOfYearTemp;
    } else {
      this.nameMonthsOfYear = MONTHS_OF_YEAR;
    }
  }

  _getEvents(List<DateTime> events) {
    this.events = Map();
    events?.forEach((date) {
      final zeroHour = _zeroHour(date);
      this.events[zeroHour.millisecondsSinceEpoch] =
          (this.events[zeroHour.millisecondsSinceEpoch] ?? 0) + 1;
    });
  }

  _getHolidays(List<DateTime> holidays) {
    this.holidays = List();
    holidays.forEach((date) {
      this.holidays.add(_zeroHour(date).millisecondsSinceEpoch);
    });
  }
}

class _CalendarState extends State<Calendar> {
  Map<int, String> nameDaysOfWeek, nameMonthsOfYear;
  List<int> disabledDays;
  DateTime firstSelected, maximumDate, minimumDate;
  Function(DateTime day) onSelectedDay;
  Map<int, int> events;
  List<int> holidays;
  Color disabledDayColor;
  Color selectedDayColor;
  Color normalDayColor;
  Color outOfRangeDayColor;
  bool showBorder;
  bool showDivider;

  //in implementation
  bool showMonth = true;

  List<DateTime> week;
  DateTime selected;
  DateTime showing;

  _CalendarState({
    this.nameDaysOfWeek,
    this.nameMonthsOfYear,
    this.firstSelected,
    this.maximumDate,
    this.minimumDate,
    this.events,
    this.holidays,
    this.disabledDays,
    this.onSelectedDay,
    this.disabledDayColor,
    this.selectedDayColor,
    this.normalDayColor,
    this.outOfRangeDayColor,
    this.showBorder = true,
    this.showDivider = true,
    /*this.showMonth = true*/
  }) {
    this.selected = firstSelected;

    DateTime focus = firstSelected ??
        minimumDate ??
        maximumDate ??
        _zeroHour(DateTime.now());

    this.week = _generateWeek(focus);
    this.showing = focus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showBorder
          ? BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Colors.black))
          : null,
      child: Center(
        child: Column(
          children: <Widget>[
            showMonth
                ? Row(
              children: <Widget>[
                _greaterThanMinimum(week.first)
                    ? FlatButton(
                  child: Text("<"),
                  onPressed: () {
                    showing = showing.add(Duration(days: -7));
                    setState(() {
                      week = _generateWeek(showing);
                    });
                  },
                )
                    : FlatButton(
                  onPressed: null,
                  child: Container(),
                ),
                Expanded(
                    child: Center(
                        child: Text(
                          nameMonthsOfYear[week.last.month] +
                              " " +
                              week.last.year.toString(),
                          style: TextStyle(fontSize: 18),
                        ))),
                _lesserThanMaximum(week.last)
                    ? FlatButton(
                  child: Text(">"),
                  onPressed: () {
                    showing = showing.add(Duration(days: 7));
                    setState(() {
                      week = _generateWeek(showing);
                    });
                  },
                )
                    : FlatButton(
                  onPressed: null,
                  child: Container(),
                ),
              ],
            )
                : Container(),
            !showMonth || !showDivider
                ? Container()
                : Divider(
              thickness: 1,
              color: Colors.black,
              height: 3,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: week.map((day) {
                return GestureDetector(
                  onTap: () {
                    if (_isOkDay(day)) {
                      setState(() {
                        this.selected = day;
                      });
                      onSelectedDay(day);
                    }
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      Text(
                        (events[_zeroHour(day).millisecondsSinceEpoch] ?? "")
                            .toString(),
                        style:
                        TextStyle(color: _getDayColor(day), fontSize: 10),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            Text(
                              nameDaysOfWeek[day.weekday].substring(0, 3),
                              style: TextStyle(
                                  fontSize: 15,
                                  color: _getDayColor(day),
                                  decoration: _isSameDay(day, DateTime.now())
                                      ? TextDecoration.underline
                                      : null),
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
      ),
    );
  }

  List<DateTime> _generateWeek(DateTime dayOfTheWeek) {
    final day = dayOfTheWeek.weekday - 1;
    return List.generate(7, (i) {
      return dayOfTheWeek.add(Duration(days: i - day));
    });
  }

  Color _getDayColor(DateTime day) {
    /*if (_isSameDay(day, DateTime.now())) {
      return Colors.green;
    } else */
    if ((minimumDate != null && day.isBefore(minimumDate)) ||
        (maximumDate != null && day.isAfter(maximumDate))) {
      return outOfRangeDayColor;
    } else if (disabledDays.contains(day.weekday) ||
        holidays.contains(_zeroHour(day).millisecondsSinceEpoch)) {
      return disabledDayColor;
    } else if (selected != null && _isSameDay(selected, day)) {
      return selectedDayColor;
    } else {
      return normalDayColor;
    }
  }

  bool _greaterThanMinimum(DateTime date) {
    if (minimumDate == null) {
      return true;
    } else {
      if (date.isAfter(minimumDate)) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool _lesserThanMaximum(DateTime date) {
    if (maximumDate == null) {
      return true;
    } else {
      if (date.isBefore(maximumDate)) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool _isOkDay(DateTime day) {
    return !((minimumDate != null && day.isBefore(minimumDate)) ||
        (maximumDate != null && day.isAfter(maximumDate)) ||
        disabledDays.contains(day.weekday) ||
        holidays.contains(_zeroHour(day).millisecondsSinceEpoch));
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
