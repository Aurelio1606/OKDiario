library event_calendar;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:proyecto/screens/home_teacher.dart';
import 'package:proyecto/services/notifications.dart';
import 'package:proyecto/services/operations.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:proyecto/screens/provider.dart';
import 'package:provider/provider.dart';

part 'appointment_editor.dart';
part 'color_picker.dart';
part 'day_picker.dart';

///list of available colors
List<Color>? _colorCollection;
///name of available colors
List<String>? _colorNames;
///index of the selected color
int _selectedColorIndex = 0;

int _selectedTimeZoneIndex = 0;
List<String>? _timeZoneCollection;
DataSource? _events;
Appointment? _selectedAppointment;

//Meeting? _aux;
//Appointmet's initial date
DateTime? _startDate;
TimeOfDay? _startTime;
//Appoinment's end date
DateTime? _endDate;
TimeOfDay? _endTime;
//all day recurrence rule
bool? _isAllDay;
//appointment's title
String _subject = '';
//appointmets's description
String _notes = '';
//appointment's recurrence rule
bool? _isRecurrence;
//recurrence options
int? _count;
int? _interval;
String? _freq;
String? _freqDayPicker;
String? _byDay;
String? _recurrenceRule;
//abbreviations day names string
String byDayChain = '';
//day names string
String dayNames = '';
//days selected by the user to repeat an appointment
String selectedDays = '';

//String? description;
//notification option, by the default is false, is desactivated
bool notification = false;
//calendar option choosen by the user, 1 by default
String selectedValue = '1';
//calendar date that will be shown
DateTime? displayDate;
//calendar date the will be picked when adding an appointment
DateTime? selectedDate;
//calendar option by default
String chosenCalendar = '1';
//user name
String user = '';

//int? anterior = -1;

//recurrence variables to choose the repetition rule
final _valueListFreq = [null, 'DAILY', 'WEEKLY', 'MONTHLY', 'PERSONALIZAR'];
final _valueListDayPickerFreq = ['DAILY', 'WEEKLY', 'MONTHLY'];
final _valueListInterval = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

class LoadDataFromFireBase extends StatelessWidget {
  const LoadDataFromFireBase({super.key});

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
  DataSnapshot? querySnapshot;
  dynamic data;

  String? dayText;
  String? nextDayText;

  @override
  void initState() {

    ///Gets the appointments from the database
    getDataFromDatabase(chosenCalendar).then((results) {
      setState(() {
        if (results != null) {
          querySnapshot = results;
        }
      });
    });

    //waits to load user name and then updates the variable user
    loadUser().then((results) {
      setState(() {
        if (results != null) {
          user = results;
        }
      });
    });

    //waits to load calendar option and updates the variable chosenCalendar
    loadCalendarOption().then((results) {
      setState(() {
        if (results != null) {
          chosenCalendar = results;
        }
      });
    });

    loadDisplayDate();
    loadSelectedDate();

    _controller = CalendarController();
    _events = DataSource(getMeetingDetails());
    _selectedAppointment = null;
    _selectedColorIndex = 0;
    _selectedTimeZoneIndex = 0;
    _subject = '';
    _notes = '';

    //Initialization to prevent null error
    dayText = 'actualDay';
    nextDayText = 'nextDay';

    super.initState();
  }

  //loads data and updates querySnapshot, which contains updated data from the database
  Future<void> loadData() async {
    var results = await getDataFromDatabase(chosenCalendar);

    if (results != null) {
      setState(() {
        querySnapshot = results;
      });
    }
  }
  
  ///builds the appBar interface
  Widget appBar(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return AppBar(
      elevation: 10,
      toolbarHeight: 120,
      automaticallyImplyLeading: false,
      leadingWidth: 100,
      actions: [
        //displayes calendar options
        PopupMenuButton<String>(
          initialValue: chosenCalendar,
          iconSize: 40,
          iconColor: Colors.black,
          color: const Color.fromARGB(255, 247, 243, 228),
          padding: const EdgeInsets.only(right: 10),
          surfaceTintColor: const Color.fromARGB(179, 255, 255, 255),
          offset: const Offset(-40, 40), //Moves menu window
          onSelected: (String value) {
            setState(() {
              selectedValue = value;
              if (selectedValue == '1') {
                //1-> current day calendar
                chosenCalendar = '1';
                //loads data depending on the calendar option choosen
                loadData();
                //saves the calendar options choosen
                setCalendarOption(userProvider.userKey, chosenCalendar);
                selectedDate = DateTime.now().add(const Duration(minutes: -60));

                _controller!.selectedDate =
                    DateTime.now().add(const Duration(minutes: -60));
                _controller!.displayDate =
                    DateTime.now().add(const Duration(minutes: -60));
                _controller!.view = CalendarView.day;
              } else if (selectedValue == '2') {
                //if the user selects week displays, the calendar option keeps as 1
                //but calendar view changes to week. Option 2 it's not saved in the database
                //it has to be choosen every time the user want to display next day
                chosenCalendar = '1';
                _controller!.view = CalendarView.week;
              
              } else if (selectedValue == '3') {
                //3->common calendar
                chosenCalendar = '3';
                //loads data depending on the calendar option choosen
                loadData();
                //saves the calendar options choosen
                setCalendarOption(userProvider.userKey, chosenCalendar);

                _controller!.selectedDate =
                    DateTime.now().add(const Duration(minutes: -60));
                _controller!.displayDate =
                    DateTime.now().add(const Duration(minutes: -60));
                _controller!.view = CalendarView.day;
              } else if (selectedValue == '4') {
                //4->next day calendar
                chosenCalendar = '4';

                //loads data depending on the calendar option choosen
                loadData();
                //saves the calendar options choosen
                setCalendarOption(userProvider.userKey, chosenCalendar);

                _controller!.selectedDate =
                    DateTime.now().add(const Duration(days: 1, minutes: -60));
                _controller!.displayDate =
                    DateTime.now().add(const Duration(days: 1, minutes: -60));
                _controller!.view = CalendarView.day;
              }
            });
          },
          itemBuilder: (BuildContext context) => [
            //calendar option names
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
      //back button
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
      backgroundColor: const Color.fromARGB(255, 157, 151, 202),
    );
  }

  ///builds the appointment's add button
  Widget addButton(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      child: FittedBox(
        child: FloatingActionButton(
          splashColor: Colors.black,
          backgroundColor: const Color.fromARGB(255, 231, 231, 231),
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
            
            //when the user press the button, the variables are initialized by default
            //and redirects the user to the appointmnet editor interface
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
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120), child: appBar(context)),
      //if the user is an admin or has the calendar option '1', the add button is shown, otherwise it is not displayed
      floatingActionButton: user == 'admin'
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
      //reference to user's calendar
      _calendarRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("CalendarData");
    } else {
      //reference to common calendar
      _calendarRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("CalendarData");
    }

    //builds the calendar interface with the data saved in the database
    return StreamBuilder<DatabaseEvent>(
      stream: _calendarRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var showData = snapshot.data!.snapshot.value;
          if (querySnapshot != null) {
            List<Meeting> collection = [];

            if (showData != null) {
              if (showData is Map<dynamic, dynamic>) {
                // Case: showData is a map
                Map<dynamic, dynamic> values = showData;
                List<dynamic> key = values.keys.toList();

                for (int i = 0; i < key.length; i++) {
                  data = values[key[i]];
                  //adds in collections a meeting object with the appointment data
                  collection.add(Meeting(
                      eventName: data['Subject'],
                      isAllDay: data['isAllDay'],
                      from: DateFormat('dd/MM/yyyy HH:mm:ss')
                          .parse(data['StartTime']),
                      to: DateFormat('dd/MM/yyyy HH:mm:ss')
                          .parse(data['EndTime']),
                      background:
                          _colorCollection![data['Color']], 
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
              
              //builds the calendar interface when the user remove all the data on it

              loadData();

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
                        headerHeight: 0, //0 to remove the header
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
            
            //builds the interface for the normale case calendar
            //where there is some data on the calendar
           
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

                      headerHeight: 0, //0 to remove the header
                      headerDateFormat: ' ',
                      controller: _controller,
                      timeSlotViewSettings: TimeSlotViewSettings(
                          timeIntervalHeight: 201,
                          timeRulerSize: 70,
                          timeInterval: const Duration(minutes: 60),
                          timeFormat: 'HH:mm',
                          dayFormat: 'EEEE',
                          //changes the number of days displayed dependeding on controller.view
                          //if it is day only shows 1 day
                          //if it is week shows 2 days
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
                              //returns dayText string which contains the day name and teh current date
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
                          //when display options is 'week' returns day text string with the day name and the current date
                          //and nextDayText with the next day name and the next day date
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
            //initial calendar interface, where there is no data 

            //If the user add a new event, the calendar display is updated
            //and shows the data
            loadData();

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
                      headerHeight: 0, //0 to remove the header
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

  ///If the user clicks on an appointment it gets its details
  ///If the user clicks on the calendar it opens the add appoinment options
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
      //reference to user's calendar
      _pruebaRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("DatosUsuario")
          .child(userProvider.userKey)
          .child("CalendarData");
    } else {
      //reference to common calendar
      _pruebaRef = FirebaseDatabase(
              databaseURL:
                  "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
          .ref()
          .child("Usuarios2")
          .child("CalendarData");
    }

    //default variables initialization
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
      //If the user clicks on an appointment
      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.appointments?.length == 1) {
        
        //gets appointment's details and initialize the variables with the data from the appointment
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

      } else {//if the user clicks on the calendar, where there is no appointment created
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


  ///Retunrs a meeting list with its details
  ///initializar the color collection and the color names 
  List<Meeting> getMeetingDetails() {
    final List<Meeting> meetingCollection = <Meeting>[];

    _colorCollection = <Color>[];
    _colorCollection?.add(const Color.fromARGB(255, 96, 196, 141));
    _colorCollection?.add(const Color.fromARGB(255, 192, 120, 212));
    _colorCollection?.add(const Color.fromARGB(255, 196, 82, 82));
    _colorCollection?.add(const Color.fromARGB(255, 212, 115, 80));
    _colorCollection?.add(const Color.fromARGB(255, 161, 109, 77));
    _colorCollection?.add(const Color.fromARGB(255, 201, 202, 101));
    _colorCollection?.add(const Color.fromARGB(255, 94, 110, 201));
    _colorCollection?.add(const Color.fromARGB(255, 219, 128, 120));
    _colorCollection?.add(const Color.fromARGB(255, 133, 129, 129));

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
            eventName: '',
          ));
        }
      }
    }

    return meetingCollection;
  }
}

///Initializes the meeting list using the data in [collection] and returns a meetingDataSource object
///that contains the appointments that will be showed on the calendar
MeetingDataSource _getCalendarDataSource(
    [List<Meeting> collection = const []]) {
  List<Meeting> meetings = collection;
  //List<CalendarResource> resourceColl = <CalendarResource>[];
  return MeetingDataSource(meetings /*resourceColl*/);
}

///Class to get appointment's data from [source] and [resourceColl]
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source /*List<CalendarResource> resourceColl*/) {
    appointments = source;
    //resources = resourceColl;
  }

  @override
  ///Returns the initial date for the appointment in [index] 
  DateTime getStartTime(int index) {
    return appointments?[index].from;
  }

  @override
  ///Returns the end date for the appointment in [index] 
  DateTime getEndTime(int index) {
    return appointments?[index].to;
  }

  @override
  ///Returns the AllDay property for the appointment in [index] 
  bool isAllDay(int index) {
    return appointments?[index].isAllDay;
  }

  @override
  ///Returns the appointment's title introduced by the user for the appointment in [index] 
  String getSubject(int index) {
    return appointments?[index].eventName;
  }

  @override
  ///Returns the appointment's color choosen by the user for the appointment in [index] 
  Color getColor(int index) {
    return appointments?[index].background;
  }

  @override
  List<Object> getResourceIds(int index) {
    return [appointments?[index].resourceId];
  }

  @override
  ///Returns the appointment's description introduced by the user for the appointment in [index] 
  String getNotes(int index) {
    return appointments?[index].notes;
  }

  @override
  ///Returns the appointment's recurrence introduced by the user for the appointment in [index] 
  String getRecurrenceRule(int index) {
    return appointments?[index].recurrenceRule;
  }
}

///Initialized the date displayed on the calendar depending on the caledar option selected
loadDisplayDate() async {
  UserProvider userProvider = UserProvider();
  String? option = await getCalendarOption(userProvider.userKey);

  if (option == '1' || option == '3') {
    //shows the current day
    displayDate = DateTime.now().add(const Duration(minutes: -60));
  } else {
    //shows the next day
    displayDate = DateTime.now().add(const Duration(days: 1, minutes: -60));
  }
}

///Initialized the date that will be selected on the calendar depending on the caledar option selected
///when the user adds a new appointment
loadSelectedDate() async {
  UserProvider userProvider = UserProvider();
  String? option = await getCalendarOption(userProvider.userKey);

  if (option == '1' || option == '3') {
    //gets the current day
    selectedDate = DateTime.now().add(const Duration(minutes: -60));
  } else {
    //gets the next day
    selectedDate = DateTime.now().add(const Duration(days: 1, minutes: -60));
  }
}

///Gets the current user's calendar options from its key and returns it
loadCalendarOption() async {
  UserProvider userProvider = UserProvider();
  String? option = await getCalendarOption(userProvider.userKey);
  return option;
}

///Gets the user's name from its key and returns it
loadUser() async {
  UserProvider userProvider = UserProvider();
  String? user = await getUser(userProvider.userKey);
  return user;
}

///Gets user's appointments from the database depending on calendar option [option]
getDataFromDatabase(String option) async {
  UserProvider userProvider = UserProvider();

  //Depending on the calendar option, the are 4 cases
  //1 -> gets the user's appointments for that day
  //3 -> gets the appointments from a common calendar, the user can't modify this calendar
  //4 -> gets the user's appointments for the next day
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

      return event.snapshot;
    } else {
      print("No se encontraron datos válidos en la base de datos.");
      return null;
    }
  }
}

///Gets the user's appointmets and creates a meetings list
Future<List<Meeting>> getEvents() async {
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
        meetingList.add(Meeting(
          eventName: data['Subject'],
          isAllDay: false,
          from: DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['StartTime']),
          to: DateFormat('dd/MM/yyyy HH:mm:ss').parse(data['EndTime']),
          background: _colorCollection![data['Color']], 
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

///Class to create the appointmets from the meeting's list
class DataSource extends CalendarDataSource {
  DataSource(List<Meeting> source) {
    appointments = source;
  }
}

///Modifies the appointments style on the calendar
Widget appointmentBuilder(BuildContext context,
    CalendarAppointmentDetails calendarAppointmentDetails) {
  final Appointment appointment = calendarAppointmentDetails.appointments.first;
  return Column(
    children: [  
      //Modifies appointmets style, making the letter bigger to make it easier to read
      //It has different styles depending on the appointments duration, that is to say, if
      //the appointmets duration is for example 30 minutes, the letter size adjusts to show the the most important
      //information.
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: (calendarAppointmentDetails.bounds.height > 116)
                          ? Column(
                              children: [
                                Text(
                                  appointment.subject,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  "Hora: " +
                                      DateFormat('HH:mm')
                                          .format(appointment.startTime) +
                                      '-' +
                                      DateFormat('HH:mm')
                                          .format(appointment.endTime),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18),
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
                                        ? const TextStyle(fontSize: 16)
                                        : const TextStyle(fontSize: 11),
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
                                        ? const TextStyle(fontSize: 16)
                                        : const TextStyle(fontSize: 11),
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
                            style: const TextStyle(fontSize: 18),
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
                        ? const TextStyle(fontSize: 16)
                        : const TextStyle(fontSize: 11),
                  ),
                  Text(
                    "    Hora: " +
                        DateFormat('HH:mm').format(appointment.startTime) +
                        '-' +
                        DateFormat('HH:mm').format(appointment.endTime),
                    textAlign: TextAlign.center,
                    style: (calendarAppointmentDetails.bounds.height > 25)
                        ? const TextStyle(fontSize: 16)
                        : const TextStyle(fontSize: 11),
                  )
                ],
              ),
      )
    ],
  );
}

///Returns the month name depending on the month number [month]
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

///Builds the interface for the month view (not used currently)
Widget monthBuilder(
    BuildContext buildContext, ScheduleViewMonthHeaderDetails details) {
  String month = getMonth(details.date.month);

  return Stack(
    children: [
      Container(
        color: const Color.fromARGB(255, 96, 171, 233),
        width: details.bounds.width,
        height: details.bounds.height,
        child: Center(
          child: Text(
            month + ' ' + details.date.year.toString(),
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}

///Returns a string with the day names from abbreviations in [shortnames]
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

///Class meeting used to create meeting from date introduced by the user.
///It is necessary to introduce initial date [from] and end date [to], the rest is optional
///as it is initialized by deafult
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
