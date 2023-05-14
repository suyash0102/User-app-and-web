import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateConverter {

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  static String dateToTimeOnly(DateTime dateTime) {
    return DateFormat(_timeFormatter()).format(dateTime);
  }

  static String dateToDateAndTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
  static String dateToDateAndTimeAm(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd ${_timeFormatter()}').format(dateTime);
  }

  static String dateTimeStringToDateTime(String dateTime) {
    return DateFormat('dd MMM yyyy  ${_timeFormatter()}').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateTimeStringToDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime));
  }

  static String dateRangeToDate(DateTimeRange range) {
    return '${DateFormat('dd-MM-yyyy').format(range.start)} - ${DateFormat('dd-MM-yyyy').format(range.end)}';
  }

  static String stringDateTimeToDate(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd').parse(dateTime));
  }

  static DateTime dateTimeStringToDate(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTime);
  }

  static DateTime isoStringToLocalDate(String dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(dateTime);
  }

  static String isoStringToLocalString(String dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(dateTime).toLocal());
  }

  static String isoStringToDateTimeString(String dateTime) {
    return DateFormat('dd MMM yyyy  ${_timeFormatter()}').format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(isoStringToLocalDate(dateTime));
  }

  static String isoStringToLocalDateTimeOnly(String dateTime) {
    return DateFormat('dd MMM yyyy HH:mm a').format(isoStringToLocalDate(dateTime));
  }

  static String stringToLocalDateOnly(String dateTime) {
    return DateFormat('dd MMM yyyy').format(DateFormat('yyyy-MM-dd').parse(dateTime));
  }

  static String localDateToIsoString(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static String convertTimeToTime(String time) {
    return DateFormat(_timeFormatter()).format(DateFormat('HH:mm').parse(time));
  }

  static DateTime convertStringTimeToDate(String time) {
    return DateFormat('HH:mm').parse(time);
  }

  static String localDateToIsoStringAMPM(DateTime dateTime) {
    return DateFormat('${_timeFormatter()} | d-MMM-yyyy ').format(dateTime.toLocal());
  }

  static String dateToTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  static bool isAvailable(String start, String end, {DateTime time, bool isoTime = false}) {
    DateTime _currentTime;
    if(time != null) {
      _currentTime = time;
    }else {
      _currentTime = Get.find<SplashController>().currentTime;
    }
    DateTime _start = start != null ? isoTime ? isoStringToLocalDate(start) : DateFormat('HH:mm').parse(start) : DateTime(_currentTime.year);
    DateTime _end = end != null ? isoTime ? isoStringToLocalDate(end) : DateFormat('HH:mm').parse(end) : DateTime(_currentTime.year, _currentTime.month, _currentTime.day, 23, 59);
    DateTime _startTime = DateTime(_currentTime.year, _currentTime.month, _currentTime.day, _start.hour, _start.minute, _start.second);
    DateTime _endTime = DateTime(_currentTime.year, _currentTime.month, _currentTime.day, _end.hour, _end.minute, _end.second);
    if(_endTime.isBefore(_startTime)) {
      if(_currentTime.isBefore(_startTime) && _currentTime.isBefore(_endTime)){
        _startTime = _startTime.add(Duration(days: -1));
      }else {
        _endTime = _endTime.add(Duration(days: 1));
      }
    }
    return _currentTime.isAfter(_startTime) && _currentTime.isBefore(_endTime);
  }

  static String _timeFormatter() {
    return Get.find<SplashController>().configModel.timeformat == '24' ? 'HH:mm' : 'hh:mm a';
  }

  static int differenceInMinute(String deliveryTime, String orderTime, int processingTime, String scheduleAt) {
    // 'min', 'hours', 'days'
    int _minTime = processingTime != null ? processingTime : 0;
    if(deliveryTime != null && deliveryTime.isNotEmpty && processingTime == null) {
      try {
        List<String> _timeList = deliveryTime.split('-'); // ['15', '20']
        _minTime = int.parse(_timeList[0]);
      }catch(e) {}
    }
    DateTime _deliveryTime = dateTimeStringToDate(scheduleAt != null ? scheduleAt : orderTime).add(Duration(minutes: _minTime));
    return _deliveryTime.difference(DateTime.now()).inMinutes;
  }

  static bool isBeforeTime(String dateTime) {
    if(dateTime == null) {
      return false;
    }
    DateTime scheduleTime = dateTimeStringToDate(dateTime);
    return scheduleTime.isBefore(DateTime.now());
  }

  static int getWeekDaysCount(DateTimeRange range, List<int> weekdays) {
    int _quantity = 0;
    DateTime _startDate = range.start;
    for(int index=0; index<(range.duration.inDays+1); index++) {
      if((_startDate.isBefore(range.end) || _startDate.isAtSameMomentAs(range.end)) && weekdays.contains(_startDate.weekday)) {
        _quantity++;
      }
      if(_startDate.isAfter(range.end)) {
        break;
      }
      _startDate = _startDate.add(Duration(days: 1));
    }
    return _quantity;
  }

  static int getMonthDaysCount(DateTimeRange range, List<int> days) {
    int _quantity = 0;
    DateTime _startDate = range.start;
    for(int index=0; index<(range.duration.inDays+1); index++) {
      if((_startDate.isBefore(range.end) || _startDate.isAtSameMomentAs(range.end)) && days.contains(_startDate.day)) {
        _quantity++;
      }
      if(_startDate.isAfter(range.end)) {
        break;
      }
      _startDate = _startDate.add(Duration(days: 1));
    }
    return _quantity;
  }

}
