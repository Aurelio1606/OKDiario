library event_calendar;

import 'dart:async';
//import 'dart:js_util';
//import 'dart:collection';
import 'dart:math';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:proyecto/screens/home_estudent.dart';
import 'package:proyecto/screens/home_teacher.dart';
import 'package:proyecto/services/notifications.dart';
import 'package:proyecto/services/operations.dart';
import 'package:proyecto/widgets/widget_top_initial.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:provider/provider.dart';

part 'appointment_editor.dart';
part 'timezone_picker.dart';
part 'color_picker.dart';
part 'day_picker.dart';

List<Color>? _colorCollection;
List<String>? _colorNames;
int _selectedColorIndex = 0;
int _selectedTimeZoneIndex = 0;
List<String>? _timeZoneCollection;
DataSource? _events;
Appointment? _selectedAppointment;
Meeting? _aux;
DateTime? _startDate;
TimeOfDay? _startTime;
DateTime? _endDate;
TimeOfDay? _endTime;
bool? _isAllDay;
String _subject = '';
String _notes = '';
bool? _isRecurrence;
int? _count;
int? _interval;
String? _freq;
String? _freqDayPicker;
String? _byDay;
String? _recurrenceRule;
String? description;
String byDayChain = '';
String dayNames = '';
String selectedDays = '';
bool notification = false;
String selectedValue = '1';
DateTime? displayDate;
DateTime? selectedDate;
String chosenCalendar = '1';
String user = '';

int? anterior = -1;

final _valueListFreq = [null, 'DAILY', 'WEEKLY', 'MONTHLY', 'PERSONALIZAR'];
final _valueListDayPickerFreq = ['DAILY', 'WEEKLY', 'MONTHLY'];
final _valueListInterval = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

class LoadDataFromFireBase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FireBase',
      home: LoadDataFromFireStore(),
    );
  }
}

class LoadDataFromFireStore extends StatefulWidget {
  final String? userKey;

  const LoadDataFromFireStore({Key? key, this.userKey}) : super(key: key);
  @override
  LoadDataFromFireStoreState createState() => LoadDataFromFireStoreState();
}

class LoadDataFromFireStoreState extends State<LoadDataFromFireStore> {
  CalendarController? _controller;
  List<String>? _eventNameCollection;
  DataSnapshot? querySnapshot;
  dynamic data;

  String? dayText;
  String? nextDayText;

  @override
  void initState() {
    _initializeEventColor();

    getDataFromDatabase(chosenCalendar).then((results) {
      setState(() {
        if (results != null) {
          querySnapshot = results;
        }
      });
    });

    loadUser().then((results) {
      setState(() {
        if (results != null) {
          user = results;
        }
      });
    });

    loadCalendarOption().then((results) {
      setState(() {
        if (results != null) {
          chosenCalendar = results;
        }
      });
    });

    print("Se inicializan");
    loadDisplayDate();
    loadSelectedDate();

    // getEvents().then((meetings) {
    //   setState(() {
    //     _events = DataSource(meetings);
    //   });
    // });

    _controller = CalendarController();
    _events = DataSource(getMeetingDetails());
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _selectedTimeZoneIndex = 0;
    _subject = '';
    _notes = '';

    dayText = 'actualDay'; //Inicialización para que no de null
    nextDayText = 'nextDay';

    super.initState();
  }

  Future<void> loadData() async {
    var results = await getDataFromDatabase(chosenCalendar);

    if (results != null) {
      setState(() {
        querySnapshot = results;
      });
    }
  }

  Widget appBar(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return AppBar(
      elevation: 10,
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      leadingWidth: 100,
      actions: [
        PopupMenuButton<String>(
          initialValue: chosenCalendar,
          iconSize: 40,
          iconColor: Colors.black,
          color: Color.fromARGB(255, 247, 243, 228),
          padding: EdgeInsets.only(right: 10),
          surfaceTintColor: Color.fromARGB(179, 255, 255, 255),
          offset: Offset(-40, 40), //* Para mover la ventana */
          onSelected: (String value) {
            setState(() {
              selectedValue = value;
              //_showCalendar();
              if (selectedValue == '1') {
                print("Calendario 1");

                chosenCalendar = '1';
                loadData();
                setCalendarOption(userProvider.userKey, chosenCalendar);
                selectedDate = DateTime.now().add(Duration(minutes: -60));

                _controller!.selectedDate =
                    DateTime.now().add(Duration(minutes: -60));
                _controller!.displayDate =
                    DateTime.now().add(Duration(minutes: -60));
                _controller!.view = CalendarView.day;
              } else if (selectedValue == '2') {
                chosenCalendar = '1';
                _controller!.view = CalendarView.week;
                // displayDate =
                //     DateTime.now().add(Duration(days: 1, minutes: -60));
              } else if (selectedValue == '3') {
                print("Calendario 3");

                chosenCalendar = '3';

                loadData();
                setCalendarOption(userProvider.userKey, chosenCalendar);

                _controller!.selectedDate =
                    DateTime.now().add(Duration(minutes: -60));
                _controller!.displayDate =
                    DateTime.now().add(Duration(minutes: -60));
                _controller!.view = CalendarView.day;
              } else if (selectedValue == '4') {
                print("Calendario 4");

                chosenCalendar = '4';

                loadData();
                setCalendarOption(userProvider.userKey, chosenCalendar);

                _controller!.selectedDate =
                    DateTime.now().add(Duration(days: 1, minutes: -60));
                _controller!.displayDate =
                    DateTime.now().add(Duration(days: 1, minutes: -60));
                _controller!.view = CalendarView.day;
              }
            });
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: '1',
              child: Text('HOY'),
            ),
            const PopupMenuItem(
              value: '2',
              child: Text('PROXIMO\nDIA'),
            ),
            const PopupMenuItem(
              value: '3',
              child: Text('FIJO'),
            ),
            const PopupMenuItem(
              value: '4',
              child: Text('MAÑANA'),
            ),
          ],
        )
      ],
      leading: IconButton(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: const EdgeInsets.only(top: 25, left: 10),
        icon: Column(
          children: <Widget>[
            const Icon(
              Icons.arrow_back,
              size: 60,
              color: Colors.black,
            ),
            Transform.translate(
              offset: const Offset(0, 3),
              child: const Text(
                'VOLVER',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
          ],
        ),
        onPressed: () {
          NavigatorState navigator = Navigator.of(context);
          navigator.push(MaterialPageRoute(builder: (context) {
            return const TeacherView();
          }));
        },
      ),
      title: const Text(
        'AGENDA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 157, 151, 202),
    );
  }

  Widget addButton(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      child: FittedBox(
        child: FloatingActionButton(
          splashColor: Colors.black,
          backgroundColor: Color.fromARGB(255, 231, 231, 231),
          child: const Column(
            children: [
              Icon(
                Icons.add,
                color: Color.fromARGB(255, 64, 158, 235),
                size: 30,
              ),
              Text(
                "AÑADIR",
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          onPressed: () {
            final DateTime date = DateTime.now();
            _startDate = date;
            _endDate = date.add(const Duration(hours: 1));

            _selectedAppointment = null;
            _isAllDay = false;
            _selectedColorIndex = 0;
            _selectedTimeZoneIndex = 0;
            _subject = '';
            _notes = '';
            _isRecurrence = false;
            _count = 1;
            _interval = 1;
            _freq = null;
            _freqDayPicker = "DAILY";
            dayNames = '';
            notification = true;

            _startTime =
                TimeOfDay(hour: _startDate!.hour, minute: _startDate!.minute);
            _endTime =
                TimeOfDay(hour: _endDate!.hour, minute: _endDate!.minute);

            switch (_startDate!.weekday) {
              case 1:
                _byDay = 'MO';
              case 2:
                _byDay = 'TU';
              case 3:
                _byDay = 'WE';
              case 4:
                _byDay = 'TH';
              case 5:
                _byDay = 'FR';
              case 6:
                _byDay = 'SA';
              case 7:
                _byDay = 'SU';
            }

            Navigator.push<Widget>(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => AppointmentEditor()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("EL USUSRIO ES $user");
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120), child: appBar(context)),
      floatingActionButton: user == 'a'
          ? addButton(context)
          : (chosenCalendar == '1' ? addButton(context) : Container()),
      body: _showCalendar(),
    );
  }

  Widget _showCalendar() {
    //print(selectedValue);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final DatabaseReference _calendarRef;

    if (chosenCalendar == '1') {
      _calendarRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("CalendarData");
    } else {
      _calendarRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("CalendarData");
    }

    return StreamBuilder<DatabaseEvent>(
      stream: _calendarRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var showData = snapshot.data!.snapshot.value;
          if (querySnapshot != null) {
            List<Meeting> collection = [];

            if (showData != null) {
              if (showData is Map<dynamic, dynamic>) {
                // Caso: showData es un mapa
                Map<dynamic, dynamic> values = showData;
                List<dynamic> key = values.keys.toList();

                for (int i = 0; i < key.length; i++) {
                  data = values[key[i]];
                  // collection ??= <Meeting>[];
                  // final Random random = new Random();
                  collection.add(Meeting(
                      eventName: data['Subject'],
                      isAllDay: data['isAllDay'],
                      from: DateFormat('dd/MM/yyyy HH:mm:ss')
                          .parse(data['StartTime']),
                      to: DateFormat('dd/MM/yyyy HH:mm:ss')
                          .parse(data['EndTime']),
                      background:
                          _colorCollection![data['Color']], //* VER COLOR */
                      notification: data['Notification'],
                      key: data['Key'],
                      description: data['Description'],
                      recurrenceRule: data['recurrenceRule']));
                }
              } else {
                print('showData no es ni un mapa ni una lista.');
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else {
              print('showData es null.');
              //*Primer if (si borro cuando ya habia antes y se queda vacio)*/

              loadData();

              //List<Meeting> collection = [];
              return Scaffold(
                  body: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: <Widget>[
                    if (_controller!.view == CalendarView.day)
                      Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 148, 195, 233),
                          border: Border.all(width: 1, color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            dayText!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    Expanded(
                      child: SfCalendar(
                        view: CalendarView.day,
                        allowedViews: const [
                          CalendarView.schedule,
                          CalendarView.month,
                          CalendarView.day,
                        ],
                        headerHeight: 0, //* 0 para quitar el header */
                        headerDateFormat: ' ',
                        controller: _controller,
                        timeSlotViewSettings: const TimeSlotViewSettings(
                            timeIntervalHeight: 201,
                            timeRulerSize: 70,
                            timeInterval: Duration(minutes: 60),
                            timeFormat: 'HH:mm',
                            dayFormat: 'EEEE',
                            timeTextStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            )),
                        viewHeaderHeight: 0,
                        onViewChanged: (ViewChangedDetails viewChangedDetails) {
                          if (_controller!.view == CalendarView.day) {
                            int dia =
                                viewChangedDetails.visibleDates[0].weekday;
                            String number = DateFormat('dd-MM-yyyy')
                                .format(viewChangedDetails.visibleDates[0])
                                .toString();
                            switch (dia) {
                              case 1:
                                dayText = 'LUNES  $number';
                                break;
                              case 2:
                                dayText = 'MARTES  $number';
                                break;
                              case 3:
                                dayText = 'MIERCOLES  $number';
                                break;
                              case 4:
                                dayText = 'JUEVES  $number';
                                break;
                              case 5:
                                dayText = 'VIERNES  $number';
                                break;
                              case 6:
                                dayText = 'SABADO  $number';
                                break;
                              case 7:
                                dayText = 'DOMINGO  $number';
                                break;
                            }
                          }
                          SchedulerBinding.instance
                              .addPostFrameCallback((duartion) {
                            setState(() {});
                          });
                        },
                        cellBorderColor: Colors.black,
                        initialSelectedDate: selectedDate,
                        initialDisplayDate: displayDate,
                        showCurrentTimeIndicator: true,
                        //showTodayButton: true,
                        //dataSource: _getCalendarDataSource(collection),
                        monthViewSettings: const MonthViewSettings(
                          showAgenda: true,
                          agendaItemHeight: 200,
                        ),
                        onTap: onCalendarTapped,
                        backgroundColor:
                            const Color.fromARGB(255, 245, 239, 216),
                        scheduleViewMonthHeaderBuilder: monthBuilder,
                        scheduleViewSettings: const ScheduleViewSettings(
                          appointmentItemHeight: 200,
                          hideEmptyScheduleWeek: true,
                          dayHeaderSettings: DayHeaderSettings(
                              dayFormat: 'EEEE',
                              width: 70,
                              dayTextStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                              dateTextStyle: TextStyle(
                                fontSize: 25,
                              )),
                          weekHeaderSettings: WeekHeaderSettings(
                            startDateFormat: 'MMMM dd',
                            endDateFormat: 'MMMM dd, yyyy',
                          ),
                        ),
                        appointmentBuilder: appointmentBuilder,
                        todayTextStyle: const TextStyle(
                          height: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ));
            }
            //print('Segundo $selectedValue');
            //* Caso normal en el que ya hay eventos y se crean mas
            return Scaffold(
                body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: <Widget>[
                  if (_controller!.view == CalendarView.day)
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 148, 195, 233),
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          dayText!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  if (_controller!.view == CalendarView.week)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 70,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 148, 195, 233),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: const Center(
                            child: Text(
                              'Hora',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: (MediaQuery.of(context).size.width - 70) / 2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 148, 195, 233),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: Text(
                            dayText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: (MediaQuery.of(context).size.width - 70) / 2,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 148, 195, 233),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            nextDayText!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  Expanded(
                    child: SfCalendar(
                      view: CalendarView.day,
                      allowedViews: const [
                        CalendarView.schedule,
                        CalendarView.week,
                        CalendarView.day,
                      ],

                      headerHeight: 0, //* 0 para quitar el header */
                      headerDateFormat: ' ',
                      controller: _controller,
                      timeSlotViewSettings: TimeSlotViewSettings(
                          timeIntervalHeight: 201,
                          timeRulerSize: 70,
                          timeInterval: Duration(minutes: 60),
                          timeFormat: 'HH:mm',
                          dayFormat: 'EEEE',
                          numberOfDaysInView:
                              CalendarView.day == _controller!.view ? -1 : 2,
                          timeTextStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          )),
                      viewHeaderHeight: 0,
                      onViewChanged: (ViewChangedDetails viewChangedDetails) {
                        if (_controller!.view == CalendarView.day) {
                          int dia = viewChangedDetails.visibleDates[0].weekday;
                          String number = DateFormat('dd-MM-yyyy')
                              .format(viewChangedDetails.visibleDates[0])
                              .toString();
                          switch (dia) {
                            case 1:
                              dayText = 'LUNES  $number';
                              break;
                            case 2:
                              dayText = 'MARTES  $number';
                              break;
                            case 3:
                              dayText = 'MIERCOLES  $number';
                              break;
                            case 4:
                              dayText = 'JUEVES  $number';
                              break;
                            case 5:
                              dayText = 'VIERNES  $number';
                              break;
                            case 6:
                              dayText = 'SABADO  $number';
                              break;
                            case 7:
                              dayText = 'DOMINGO  $number';
                              break;
                          }
                        } else if (_controller!.view == CalendarView.week) {
                          int dia = viewChangedDetails.visibleDates[0].weekday;
                          String number = DateFormat('dd-MM-yyyy')
                              .format(viewChangedDetails.visibleDates[0])
                              .toString();
                          String number2 = DateFormat('dd-MM-yyyy')
                              .format(viewChangedDetails.visibleDates[1])
                              .toString();
                          switch (dia) {
                            case 1:
                              dayText = 'LUNES  $number';
                              nextDayText = 'MARTES  $number2';
                              break;
                            case 2:
                              dayText = 'MARTES  $number';
                              nextDayText = 'MIERCOLES  $number2';
                              break;
                            case 3:
                              dayText = 'MIERCOLES  $number';
                              nextDayText = 'JUEVES  $number2';
                              break;
                            case 4:
                              dayText = 'JUEVES  $number';
                              nextDayText = 'VIERNES  $number2';
                              break;
                            case 5:
                              dayText = 'VIERNES  $number';
                              nextDayText = 'SABADO  $number2';
                              break;
                            case 6:
                              dayText = 'SABADO  $number';
                              nextDayText = 'DOMINGO  $number2';
                              break;
                            case 7:
                              dayText = 'DOMINGO  $number';
                              nextDayText = 'LUNES  $number2';
                              break;
                          }
                        }
                        SchedulerBinding.instance
                            .addPostFrameCallback((duartion) {
                          setState(() {});
                        });
                      },
                      cellBorderColor: Colors.black,
                      initialSelectedDate: displayDate,
                      initialDisplayDate: selectedDate,
                      showCurrentTimeIndicator: true,
                      //showTodayButton: true,
                      dataSource: _getCalendarDataSource(collection),
                      monthViewSettings: const MonthViewSettings(
                        showAgenda: true,
                        agendaItemHeight: 200,
                      ),
                      onTap: onCalendarTapped,
                      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
                      scheduleViewMonthHeaderBuilder: monthBuilder,
                      scheduleViewSettings: const ScheduleViewSettings(
                        appointmentItemHeight: 200,
                        hideEmptyScheduleWeek: true,
                        dayHeaderSettings: DayHeaderSettings(
                            dayFormat: 'EEEE',
                            width: 70,
                            dayTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            dateTextStyle: TextStyle(
                              fontSize: 25,
                            )),
                        weekHeaderSettings: WeekHeaderSettings(
                          startDateFormat: 'MMMM dd',
                          endDateFormat: 'MMMM dd, yyyy',
                        ),
                      ),
                      appointmentBuilder: appointmentBuilder,
                      todayTextStyle: const TextStyle(
                        height: 1,
                      ),
                    ),
                  )
                ],
              ),
            ));
          } else {
            //*If inicial donde tdv no se ha creado nunca nada

            loadData();

            //List<Meeting> collection = [];
            return Scaffold(
                body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: <Widget>[
                  if (_controller!.view == CalendarView.day)
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 148, 195, 233),
                        border: Border.all(width: 1, color: Colors.black),
                      ),
                      child: Center(
                        child: Text(
                          dayText!,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SfCalendar(
                      view: CalendarView.day,
                      allowedViews: const [
                        CalendarView.schedule,
                        CalendarView.month,
                        CalendarView.day,
                      ],
                      headerHeight: 0, //* 0 para quitar el header */
                      headerDateFormat: ' ',
                      controller: _controller,
                      timeSlotViewSettings: const TimeSlotViewSettings(
                          timeIntervalHeight: 201,
                          timeRulerSize: 70,
                          timeInterval: Duration(minutes: 60),
                          timeFormat: 'HH:mm',
                          dayFormat: 'EEEE',
                          timeTextStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          )),
                      viewHeaderHeight: 0,
                      onViewChanged: (ViewChangedDetails viewChangedDetails) {
                        if (_controller!.view == CalendarView.day) {
                          int dia = viewChangedDetails.visibleDates[0].weekday;
                          String number = DateFormat('dd-MM-yyyy')
                              .format(viewChangedDetails.visibleDates[0])
                              .toString();
                          switch (dia) {
                            case 1:
                              dayText = 'LUNES  $number';
                              break;
                            case 2:
                              dayText = 'MARTES  $number';
                              break;
                            case 3:
                              dayText = 'MIERCOLES  $number';
                              break;
                            case 4:
                              dayText = 'JUEVES  $number';
                              break;
                            case 5:
                              dayText = 'VIERNES  $number';
                              break;
                            case 6:
                              dayText = 'SABADO  $number';
                              break;
                            case 7:
                              dayText = 'DOMINGO  $number';
                              break;
                          }
                        }
                        SchedulerBinding.instance
                            .addPostFrameCallback((duartion) {
                          setState(() {});
                        });
                      },
                      cellBorderColor: Colors.black,
                      initialSelectedDate: selectedDate,
                      initialDisplayDate: displayDate,
                      showCurrentTimeIndicator: true,
                      //showTodayButton: true,
                      //dataSource: _getCalendarDataSource(collection),
                      monthViewSettings: const MonthViewSettings(
                        showAgenda: true,
                        agendaItemHeight: 200,
                      ),
                      onTap: onCalendarTapped,
                      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
                      scheduleViewMonthHeaderBuilder: monthBuilder,
                      scheduleViewSettings: const ScheduleViewSettings(
                        appointmentItemHeight: 200,
                        hideEmptyScheduleWeek: true,
                        dayHeaderSettings: DayHeaderSettings(
                            dayFormat: 'EEEE',
                            width: 70,
                            dayTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            dateTextStyle: TextStyle(
                              fontSize: 25,
                            )),
                        weekHeaderSettings: WeekHeaderSettings(
                          startDateFormat: 'MMMM dd',
                          endDateFormat: 'MMMM dd, yyyy',
                        ),
                      ),
                      appointmentBuilder: appointmentBuilder,
                      todayTextStyle: const TextStyle(
                        height: 1,
                      ),
                    ),
                  )
                ],
              ),
            ));
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void onCalendarTapped(CalendarTapDetails calendarTapDetails) async {

    if(user != 'a' && (chosenCalendar == '3' || chosenCalendar == '4') ){
      return;
    }

    if (calendarTapDetails.targetElement != CalendarElement.calendarCell &&
        calendarTapDetails.targetElement != CalendarElement.appointment) {
      return;
    }

    UserProvider userProvider = UserProvider();
    final DatabaseReference _pruebaRef;

    if (chosenCalendar == '1') {
      _pruebaRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("CalendarData");
    } else {
      _pruebaRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("CalendarData");
    }

    _selectedAppointment = null;
    _isAllDay = false;
    _selectedColorIndex = 0;
    _selectedTimeZoneIndex = 0;
    _subject = '';
    _notes = '';
    _isRecurrence = false;

    _count = 1;
    _freq = null;
    _interval = 1;
    _byDay = '';
    selectedDays = '';
    dayNames = '';
    notification = false;
    _freqDayPicker = 'DAILY';

    if (_controller?.view == CalendarView.month) {
      _controller?.view = CalendarView.day;
    } else {
      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.appointments?.length == 1) {
        print(calendarTapDetails.appointments?[0]);

        final Appointment meetingDetails = calendarTapDetails.appointments?[0];
        _startDate = meetingDetails.startTime;
        _endDate = meetingDetails.endTime;
        _isAllDay = meetingDetails.isAllDay;
        _recurrenceRule = meetingDetails.recurrenceRule;

        final notficatioValue =
            await _pruebaRef.child(meetingDetails.location!).get();
        notification = (notficatioValue.value as Map)['Notification'];

        if (_recurrenceRule == 'FREQ=DAILY;INTERVAL=1;COUNT=1') {
          _isRecurrence = false;
        } else {
          _isRecurrence = true;
          List<String> partsRecurrenceRule = _recurrenceRule!.split(";");
          //print(partsRecurrenceRule);
          _freq = partsRecurrenceRule[0].substring(5);
          _interval = int.parse(partsRecurrenceRule[1].substring(9));
          _count = int.parse(partsRecurrenceRule[2].substring(6));
          if (_freq == "WEEKLY") {
            _byDay = partsRecurrenceRule[3].substring(6);
            selectedDays = dayNamesChain(_byDay!);
            dayNames = selectedDays;
          }
        }

        _selectedColorIndex = _colorCollection!.indexOf(meetingDetails.color);
        _selectedTimeZoneIndex = (meetingDetails.startTimeZone == ''
            ? 0
            : _timeZoneCollection?.indexOf(meetingDetails.startTimeZone!))!;
        _subject = meetingDetails.subject == '(SIN TITULO)'
            ? ''
            : meetingDetails.subject;
        _notes = meetingDetails.notes!.toUpperCase();
        _selectedAppointment = meetingDetails;
      } else {
        final DateTime? date = calendarTapDetails.date;

        _startDate = date;
        _endDate = date?.add(const Duration(hours: 1));
      }
      _startTime =
          TimeOfDay(hour: _startDate!.hour, minute: _startDate!.minute);
      _endTime = TimeOfDay(hour: _endDate!.hour, minute: _endDate!.minute);
      Navigator.push<Widget>(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => AppointmentEditor()),
      );
    }
  }

  void _initializeEventColor() {
    _colorCollection = <Color>[];
    _colorCollection?.add(const Color(0xFF0F8644));
    _colorCollection?.add(const Color(0xFF8B1FA9));
    _colorCollection?.add(const Color(0xFFD20100));
    _colorCollection?.add(const Color(0xFFFC571D));
    _colorCollection?.add(const Color(0xFF36B37B));
    _colorCollection?.add(const Color(0xFF01A1EF));
    _colorCollection?.add(const Color(0xFF3D4FB5));
    _colorCollection?.add(const Color(0xFFE47C73));
    _colorCollection?.add(const Color(0xFF636363));
    _colorCollection?.add(const Color(0xFF0A8043));
  }

  List<Meeting> getMeetingDetails() {
    final List<Meeting> meetingCollection = <Meeting>[];
    _eventNameCollection = <String>[];
    _eventNameCollection?.add('General Meeting');
    _eventNameCollection?.add('Plan Execution');
    _eventNameCollection?.add('Project Plan');
    _eventNameCollection?.add('Consulting');
    _eventNameCollection?.add('Support');
    _eventNameCollection?.add('Development Meeting');
    _eventNameCollection?.add('Scrum');
    _eventNameCollection?.add('Project Completion');
    _eventNameCollection?.add('Release updates');
    _eventNameCollection?.add('Performance Check');

    _colorCollection = <Color>[];
    _colorCollection?.add(Color.fromARGB(255, 96, 196, 141));
    _colorCollection?.add(Color.fromARGB(255, 192, 120, 212));
    _colorCollection?.add(Color.fromARGB(255, 196, 82, 82));
    _colorCollection?.add(Color.fromARGB(255, 212, 115, 80));
    _colorCollection?.add(Color.fromARGB(255, 161, 109, 77));
    _colorCollection?.add(Color.fromARGB(255, 201, 202, 101));
    _colorCollection?.add(Color.fromARGB(255, 94, 110, 201));
    _colorCollection?.add(Color.fromARGB(255, 219, 128, 120));
    _colorCollection?.add(Color.fromARGB(255, 133, 129, 129));

    _colorNames = <String>[];
    _colorNames?.add('VERDE');
    _colorNames?.add('MORADO');
    _colorNames?.add('ROJO');
    _colorNames?.add('NARANJA');
    _colorNames?.add('MARRON');
    _colorNames?.add('AMARILLO');
    _colorNames?.add('AZUL');
    _colorNames?.add('ROSA');
    _colorNames?.add('GRIS');

    _timeZoneCollection = <String>[];
    _timeZoneCollection?.add('Default Time');

    final DateTime today = DateTime.now();
    final Random random = Random();
    for (int month = -1; month < 2; month++) {
      for (int day = -5; day < 5; day++) {
        for (int hour = 9; hour < 18; hour += 5) {
          meetingCollection.add(Meeting(
            from: today
                .add(Duration(days: (month * 30) + day))
                .add(Duration(hours: hour)),
            to: today
                .add(Duration(days: (month * 30) + day))
                .add(Duration(hours: hour + 2)),
            background: _colorCollection![random.nextInt(9)],
            startTimeZone: '',
            endTimeZone: '',
            description: '',
            isAllDay: false,
            eventName: _eventNameCollection![random.nextInt(7)],
          ));
        }
      }
    }

    return meetingCollection;
  }
}

MeetingDataSource _getCalendarDataSource(
    [List<Meeting> collection = const []]) {
  List<Meeting> meetings = collection;
  List<CalendarResource> resourceColl = <CalendarResource>[];
  return MeetingDataSource(meetings, resourceColl);
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments?[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments?[index].to;
  }

  @override
  bool isAllDay(int index) {
    return appointments?[index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments?[index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments?[index].background;
  }

  @override
  List<Object> getResourceIds(int index) {
    return [appointments?[index].resourceId];
  }

  @override
  String getNotes(int index) {
    return appointments?[index].notes;
  }

  @override
  String getRecurrenceRule(int index) {
    return appointments?[index].recurrenceRule;
  }
}

loadDisplayDate() async {
  UserProvider userProvider = UserProvider();
  String? option = await getCalendarOption(userProvider.userKey);

  if (option == '1' || option == '3') {
    displayDate = DateTime.now().add(Duration(minutes: -60));
  } else {
    displayDate = DateTime.now().add(Duration(days: 1, minutes: -60));
  }
}

loadSelectedDate() async {
  UserProvider userProvider = UserProvider();
  String? option = await getCalendarOption(userProvider.userKey);

  if (option == '1' || option == '3') {
    selectedDate = DateTime.now().add(Duration(minutes: -60));
  } else {
    selectedDate = DateTime.now().add(Duration(days: 1, minutes: -60));
  }
}

loadCalendarOption() async {
  UserProvider userProvider = UserProvider();
  String? option = await getCalendarOption(userProvider.userKey);
  return option;
}

loadUser() async {
  UserProvider userProvider = UserProvider();
  String? user = await getUser(userProvider.userKey);
  return user;
}

getDataFromDatabase(String option) async {
  UserProvider userProvider = UserProvider();

  print("Opcion selected $option ");

  if (option == '1') {
    final DatabaseReference _calendarRef = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("DatosUsuario")
        .child(userProvider.userKey)
        .child("CalendarData");

    var event = await _calendarRef.once();
    if (event.snapshot.value != null) {
      print("debajo");
      print(event.snapshot.value);

      return event.snapshot;
    } else {
      print("No se encontraron datos válidos en la base de datos.");
      return null;
    }
  } else if (option == '3') {
    final DatabaseReference _calendarRef = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("CalendarData");

    var event = await _calendarRef.once();
    if (event.snapshot.value != null) {
      print("debajo");
      print(event.snapshot.value);

      return event.snapshot;
    } else {
      print("No se encontraron datos válidos en la base de datos.");
      return null;
    }
  } else if (option == '4') {
    final DatabaseReference _calendarRef = FirebaseDatabase(
            databaseURL:
                "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
        .ref()
        .child("Usuarios2")
        .child("CalendarData");

    var event = await _calendarRef.once();
    if (event.snapshot.value != null) {
      print("debajo");
      print(event.snapshot.value);

      return event.snapshot;
    } else {
      print("No se encontraron datos válidos en la base de datos.");
      return null;
    }
  }
}

Future<List<Meeting>> getEvents() async {
  //* COMPROBAR */
  UserProvider userProvider = UserProvider();

  final DatabaseReference _calendarRef = FirebaseDatabase(
          databaseURL:
              "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
      .ref()
      .child("Usuarios2")
      .child("DatosUsuario")
      .child(userProvider.userKey)
      .child("CalendarData");

  var event = await _calendarRef.once();
  if (event.snapshot.value != null) {
    var showData = event.snapshot.value;
    List<Meeting> meetingList = [];

    if (showData is Map<dynamic, dynamic>) {
      Map<dynamic, dynamic> values = showData;
      List<dynamic> key = values.keys.toList();

      for (int i = 0; i < key.length; i++) {
        var data = values[key[i]];
        //final Random random = new Random();
        print(data);
        meetingList.add(Meeting(
          eventName: data['Subject'],
          isAllDay: false,
          from: DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['StartTime']),
          to: DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['EndTime']),
          background: _colorCollection![data['Color']], //* VER COLOR */
          notification: data['Notification'],
          key: data['Key'],
          recurrenceRule: data['recurrenceRule'],
        ));
      }
    }

    return meetingList;
  } else {
    print("No se encontraron datos válidos en la base de datos.");
    return [];
  }
}

class DataSource extends CalendarDataSource {
  DataSource(List<Meeting> source) {
    appointments = source;
  }
}

Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  //print(calendarAppointmentDetails.bounds.height);
  return Column(
    children: [
      // Container(
      //   width: calendarAppointmentDetails.bounds.width,
      //   height: calendarAppointmentDetails.bounds.height/2,
      //   decoration: BoxDecoration(
      //     color: appointment.color,
      //     border: Border.all(color: Colors.black, width: 1),
      //     borderRadius: const BorderRadius.only(
      //         topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      //   ),
      //   child: Column(
      //     children: [
      //       Text(
      //         appointment.subject,
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 18),
      //       ),
      //       Text(
      //         "Hora: " +
      //             DateFormat('HH:mm').format(appointment.startTime) +
      //             '-' +
      //             DateFormat('HH:mm').format(appointment.endTime),
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 18),
      //       )
      //     ],
      //   ),
      // ),
      Container(
        width: calendarAppointmentDetails.bounds.width,
        height: calendarAppointmentDetails.bounds.height,
        decoration: BoxDecoration(
          color: appointment.color,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: (calendarAppointmentDetails.bounds.height > 50)
            ? Column(
                children: [
                  // Icono centrado verticalmente junto con el texto "Ubicacion"
                  // const Padding(
                  //   padding: EdgeInsets.only(left: 2),
                  //   child: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Icon(
                  //         Icons.location_on_sharp,
                  //       ),
                  //       Text(
                  //         "Ubicacion",
                  //         style: TextStyle(fontSize: 15),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const VerticalDivider(
                  //   thickness: 1,
                  //   color: Colors.black,
                  // ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: (calendarAppointmentDetails.bounds.height > 116)
                          ? Column(
                              children: [
                                Text(
                                  appointment.subject,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  "Hora: " +
                                      DateFormat('HH:mm')
                                          .format(appointment.startTime) +
                                      '-' +
                                      DateFormat('HH:mm')
                                          .format(appointment.endTime),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                                const Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    appointment.subject,
                                    textAlign: TextAlign.center,
                                    style: (calendarAppointmentDetails
                                                .bounds.height >
                                            80)
                                        ? TextStyle(fontSize: 16)
                                        : TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    "     Hora: " +
                                        DateFormat('HH:mm')
                                            .format(appointment.startTime) +
                                        '-' +
                                        DateFormat('HH:mm')
                                            .format(appointment.endTime),
                                    textAlign: TextAlign.center,
                                    style: (calendarAppointmentDetails
                                                .bounds.height >
                                            80)
                                        ? TextStyle(fontSize: 16)
                                        : TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.notes!.toString().toUpperCase(),
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.subject,
                    textAlign: TextAlign.center,
                    style: (calendarAppointmentDetails.bounds.height > 25)
                        ? TextStyle(fontSize: 16)
                        : TextStyle(fontSize: 11),
                  ),
                  Text(
                    "    Hora: " +
                        DateFormat('HH:mm').format(appointment.startTime) +
                        '-' +
                        DateFormat('HH:mm').format(appointment.endTime),
                    textAlign: TextAlign.center,
                    style: (calendarAppointmentDetails.bounds.height > 25)
                        ? TextStyle(fontSize: 16)
                        : TextStyle(fontSize: 11),
                  )
                ],
              ),
      )
    ],
  );
}

String getMonth(int month) {
  if (month == 01) {
    return 'ENERO';
  } else if (month == 02) {
    return 'FEBRERO';
  } else if (month == 03) {
    return 'MARZO';
  } else if (month == 04) {
    return 'ABRIL';
  } else if (month == 05) {
    return 'MAYO';
  } else if (month == 06) {
    return 'JUNIO';
  } else if (month == 07) {
    return 'JULIO';
  } else if (month == 08) {
    return 'AGOSTO';
  } else if (month == 09) {
    return 'SEPTIEMBRE';
  } else if (month == 10) {
    return 'OCTUBRE';
  } else if (month == 11) {
    return 'NOVIEMBRE';
  } else {
    return 'DICIEMBRE';
  }
}

Widget monthBuilder(
    BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
  String month = getMonth(details.date.month);

  return Stack(
    children: [
      Container(
        color: Color.fromARGB(255, 96, 171, 233),
        width: details.bounds.width,
        height: details.bounds.height,
        child: Center(
          child: Text(
            month + ' ' + details.date.year.toString(),
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      // Positioned(
      //   left: 55,
      //   right: 0,
      //   top: 20,
      //   bottom: 0,
      //   child: Text(
      //     month + ' ' + details.date.year.toString(),
      //     style: TextStyle(fontSize: 18),
      //   ),
      // )
    ],
  );
}

String dayNamesChain(String shortNames) {
  final selected = shortNames.split(',');

  final Map<String, String> daysNames = {
    'MO': 'LUNES',
    'TU': 'MARTES',
    'WE': 'MIERCOLES',
    'TH': 'JUEVES',
    'FR': 'VIERNES',
    'SA': 'SABADO',
    'SU': 'DOMINGO',
  };

  final completeNames = selected.map((dia) {
    return daysNames[dia] ??
        dia; // Usa el nombre completo si está disponible, de lo contrario, deja la abreviatura.
  });

  return completeNames.join(', ');
}

class Meeting extends Appointment {
  Meeting(
      {required this.from,
      required this.to,
      this.eventName = '',
      this.background = Colors.green,
      this.isAllDay = false,
      this.notification = false,
      this.startTimeZone = '',
      this.endTimeZone = '',
      this.description = '',
      this.key = '',
      this.recurrenceRule = "DAILY"})
      : super(
          startTime: from,
          endTime: to,
          color: background,
          notes: description,
          subject: eventName,
          isAllDay: isAllDay,
          recurrenceRule: recurrenceRule,
          location: key,
        );

  final DateTime from;
  final DateTime to;
  final String eventName;
  final Color background;
  final bool isAllDay;
  final bool notification;
  final String startTimeZone;
  final String endTimeZone;
  final String description;
  final String key;
  final String recurrenceRule;
}
