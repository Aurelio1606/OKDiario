part of event_calendar;

class AppointmentEditor extends StatefulWidget {
  @override
  AppointmentEditorState createState() => AppointmentEditorState();
}

class AppointmentEditorState extends State<AppointmentEditor> {
  String? key = '';

  ///Returns day intial according to [day]
  String getByday(int day) {
    switch (day) {
      case 1:
        return _byDay = 'MO';
      case 2:
        return _byDay = 'TU';
      case 3:
        return _byDay = 'WE';
      case 4:
        return _byDay = 'TH';
      case 5:
        return _byDay = 'FR';
      case 6:
        return _byDay = 'SA';
      case 7:
        return _byDay = 'SU';
    }
    return '';
  }

  ///Return diferrence between two days [first] and [second]
  int getDiff(int first, int second) {
    if (first > second) {
      return first - second;
    } else {
      return second - first;
    }
  }

  ///Returns an unique Id for a notification
  int generateUniqueId() {
    DateTime now = DateTime.now();
    int random = Random().nextInt(100000);
    int uniqueId = now.microsecond + random;

    return uniqueId;
  }

  ///builds appintment editor interface
  Widget _getAppointmentEditor(BuildContext context) {

    return Container(
        color: const Color.fromARGB(255, 245, 239, 216),
        //Section to write the appointment's title 
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            ListTile(
              tileColor: const Color.fromARGB(255, 245, 239, 216),
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: TextEditingController(text: _subject),
                onChanged: (String value) {
                  _subject = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'TITULO',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
           //Section to set appointment's start date
            ListTile(
                tileColor: const Color.fromARGB(255, 245, 239, 216),
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                                DateFormat('EEEE', 'es')
                                    .format(_startDate!)
                                    .toUpperCase(),
                                textAlign: TextAlign.left),
                            onTap: () async {
                              final DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: _startDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100),
                                  helpText: "SELECCIONAR FECHA",
                                  builder: (context, child) {
                                    return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Color.fromARGB(
                                                255, 225, 220, 130),
                                            onPrimary: Colors.black,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                        255,
                                                        0,
                                                        0,
                                                        0), // button text color
                                                textStyle: const TextStyle(
                                                  fontSize:
                                                      22, // button text size
                                                )),
                                          ),
                                        ),
                                        child: child!);
                                  });

                              if (date != null && date != _startDate) {
                                setState(() {
                                  final Duration difference =
                                      _endDate!.difference(_startDate!);
                                  _startDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      _startTime!.hour,
                                      _startTime!.minute,
                                      0);
                                  _endDate = _startDate?.add(difference);
                                  _endTime = TimeOfDay(
                                      hour: _endDate!.hour,
                                      minute: _endDate!.minute);

                                  _byDay = getByday(_startDate!.weekday);
                                });
                              }
                            }),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay!
                              ? const Text('')
                              : GestureDetector(
                                  child: Text(
                                    DateFormat('HH:mm').format(_startDate!),
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? time =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay(
                                          hour: _startTime!.hour,
                                          minute: _startTime!.minute),
                                      initialEntryMode:
                                          TimePickerEntryMode.input,
                                      hourLabelText: "HORA",
                                      minuteLabelText: "MINUTO",
                                      helpText: "INTRODUCIR HORA",
                                    );

                                    if (time != null && time != _startTime) {
                                      setState(() {
                                        _startTime = time;
                                        final Duration difference =
                                            _endDate!.difference(_startDate!);
                                        _startDate = DateTime(
                                            _startDate!.year,
                                            _startDate!.month,
                                            _startDate!.day,
                                            _startTime!.hour,
                                            _startTime!.minute,
                                            0);
                                        _endDate = _startDate?.add(difference);
                                        _endTime = TimeOfDay(
                                            hour: _endDate!.hour,
                                            minute: _endDate!.minute);
                                      });
                                    }
                                  })),
                    ])),
            //Section to set appointment's finish date
            ListTile(
                tileColor: const Color.fromARGB(255, 245, 239, 216),
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 7,
                        child: GestureDetector(
                            child: Text(
                              DateFormat('EEEE', 'es')
                                  .format(_endDate!)
                                  .toUpperCase(),
                              textAlign: TextAlign.left,
                            ),
                            onTap: () async {
                              final DateTime? date = await showDatePicker(
                                  context: context,
                                  initialDate: _endDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2100),
                                  helpText: "SELECCIONAR FECHA",
                                  builder: (context, child) {
                                    return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: Color.fromARGB(
                                                255, 225, 220, 130),
                                            onPrimary: Colors.black,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                        255,
                                                        0,
                                                        0,
                                                        0), // button text color
                                                textStyle: const TextStyle(
                                                  fontSize:
                                                      22, // button text size
                                                )),
                                          ),
                                        ),
                                        child: child!);
                                  });

                              if (date != null && date != _endDate) {
                                setState(() {
                                  final Duration difference =
                                      _endDate!.difference(_startDate!);
                                  _endDate = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      _endTime!.hour,
                                      _endTime!.minute,
                                      0);
                                  if (_endDate!.isBefore(_startDate!)) {
                                    _startDate = _endDate?.subtract(difference);
                                    _startTime = TimeOfDay(
                                        hour: _startDate!.hour,
                                        minute: _startDate!.minute);
                                  }
                                });
                              }
                            }),
                      ),
                      Expanded(
                          flex: 3,
                          child: _isAllDay!
                              ? const Text('')
                              : GestureDetector(
                                  child: Text(
                                    DateFormat('HH:mm').format(_endDate!),
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? time =
                                        await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay(
                                                hour: _endTime!.hour,
                                                minute: _endTime!.minute),
                                            initialEntryMode:
                                                TimePickerEntryMode.input,
                                            hourLabelText: "HORA",
                                            minuteLabelText: "MINUTO",
                                            helpText: "INTRODUCIR HORA");

                                    if (time != null && time != _endTime) {
                                      setState(() {
                                        _endTime = time;
                                        final Duration? difference =
                                            _endDate?.difference(_startDate!);
                                        _endDate = DateTime(
                                            _endDate!.year,
                                            _endDate!.month,
                                            _endDate!.day,
                                            _endTime!.hour,
                                            _endTime!.minute,
                                            0);
                                        if (_endDate!.isBefore(_startDate!)) {
                                          _startDate =
                                              _endDate?.subtract(difference!);
                                          _startTime = TimeOfDay(
                                              hour: _startDate!.hour,
                                              minute: _startDate!.minute);
                                        }
                                      });
                                    }
                                  })),
                    ])),
            //section to choose wheter to repeat the appointment or not
            ListTile(
              tileColor: const Color.fromARGB(255, 245, 239, 216),
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: const Icon(
                Icons.repeat,
                color: Colors.black87,
              ),
              title: Row(
                children: [
                  const Expanded(
                    child: Text("REPETIR"),
                  ),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerRight,
                    child: Switch(
                      value: _isRecurrence!,
                      onChanged: (bool value) {
                        setState(() {
                          _isRecurrence = value;
                        });
                      },
                    ),
                  ))
                ],
              ),
            ),
            if (_isRecurrence!)
              //If the appointment will repeat, it unfolds a menu where to choose different recurrence's options
              //it can be [daily], [weekly], [monthly] or [Personalizar]
              ListTile(
                tileColor: const Color.fromARGB(255, 245, 239, 216),
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      constraints:
                          const BoxConstraints(maxWidth: 300, maxHeight: 300),
                      child: DropdownButton(
                        value: _freq,
                        isExpanded: true,
                        itemHeight: null,
                        iconSize: 30,
                        iconEnabledColor: Colors.black,
                        items: _valueListFreq.map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: (item == null)
                                ? const Text("SELECCIONAR")
                                : (item == 'DAILY')
                                    ? const Text("CADA DIA")
                                    : (item == 'WEEKLY')
                                        ? Text(dayNames.isNotEmpty
                                            ? "CADA ${_interval == 1 ? 'SEMANA' : '$_interval SEMANAS'} EL $selectedDays"
                                            : "CADA SEMANA EL ${DateFormat('EEEE', 'es').format(_startDate!).toUpperCase()}")
                                        : (item == 'PERSONALIZAR')
                                            ? const Text("PERSONALIZAR...")
                                            : const Text("CADA MES"),
                          );
                        }).toList(),
                        onChanged: (item) {
                          setState(() {
                            //if personalizar is choseen, a new window will be display where user can chose the appointment recurrence
                            //it can be [daily], [weekly] where they can chose the days they want for the appointment and [monthly]
                            if (item == 'PERSONALIZAR') {
                              showDialog<Widget>(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return _DayPicker();
                                },
                              ).then((dynamic value) => setState(() {
                                    selectedDays = dayNames;
                                    _count = 90;
                                  }));
                            } else {
                              _freq = item;
                              _count = 60;
                              _interval = 1;
                              _byDay = getByday(_startDate!.weekday);
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            //Section that allows the user to set a reminder 
            ListTile(
                tileColor: const Color.fromARGB(255, 245, 239, 216),
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Icon(
                  Icons.access_time,
                  color: Colors.black54,
                ),
                title: Row(children: <Widget>[
                  const Expanded(
                    child: Text('ACTIVAR RECORDATORIO'),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: notification,
                            onChanged: (bool value) {
                              setState(() {
                                notification = value;
                              });
                            },
                          ))),
                ])),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            //Section that allows the user to chose appointment's color
            ListTile(
              tileColor: const Color.fromARGB(255, 245, 239, 216),
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens,
                  color: _colorCollection?[_selectedColorIndex]),
              title: Text(
                _colorNames![_selectedColorIndex],
              ),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return _ColorPicker();
                  },
                ).then((dynamic value) => setState(() {}));
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            //Section where the user can add a brief description about the appointment
            ListTile(
              tileColor: const Color.fromARGB(255, 245, 239, 216),
              contentPadding: const EdgeInsets.all(5),
              leading: const Icon(
                Icons.subject,
                color: Colors.black87,
              ),
              title: TextField(
                controller: TextEditingController(text: _notes),
                onChanged: (String value) {
                  _notes = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'DESCRIPCION',
                ),
              ),
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
          ],
        ));
  }

  @override
  Widget build([BuildContext? context]) {
    final userProvider = Provider.of<UserProvider>(context!, listen: false);

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

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            //builds the appbar
            appBar: AppBar(
              title: const Center(
                  child: Text(
                "DETALLES",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              )),
              toolbarHeight: 100,
              backgroundColor: _colorCollection?[_selectedColorIndex],
              leadingWidth: 75,
              leading: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 35,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "CERRAR",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      IconButton(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          icon: const Icon(
                            Icons.done,
                            color: Colors.black,
                            size: 35,
                          ),
                          //if the "tick" button is pressed, it will save the appointment's information in the database if it's new
                          //or updates the information if the appointment  already existed 
                          //the "cross" button closes the appointment editor 
                          onPressed: () async {
                            final List<Meeting> meetings = <Meeting>[];
                            if (_selectedAppointment != null) {
                              _events!.appointments?.removeWhere(
                                  (meeting) => 
                                      meeting.from ==
                                          _selectedAppointment?.startTime &&
                                      meeting.to ==
                                          _selectedAppointment?.endTime);

                              key = _selectedAppointment!
                                  .location; 
                              

                              final DatabaseReference _updateRef;

                              if (chosenCalendar == '1') {
                                _updateRef = FirebaseDatabase(
                                        databaseURL:
                                            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
                                    .ref()
                                    .child("Usuarios2")
                                    .child("DatosUsuario")
                                    .child(userProvider.userKey)
                                    .child("CalendarData")
                                    .child(key!);
                              } else {
                                _updateRef = FirebaseDatabase(
                                        databaseURL:
                                            "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
                                    .ref()
                                    .child("Usuarios2")
                                    .child("CalendarData")
                                    .child(key!);
                                
                              }

                              _updateRef.update({
                                "Key": key,
                                "StartTime": DateFormat('dd/MM/yyyy HH:mm:ss')
                                    .format(_startDate!),
                                "EndTime": DateFormat('dd/MM/yyyy HH:mm:ss')
                                    .format(_endDate!),
                                "Subject":
                                    _subject == '' ? 'SIN TITULO' : _subject,
                                "Notification": notification,
                                "Color": _selectedColorIndex,
                                "isAllDay": _isAllDay,
                                "Description": _notes,
                                "recurrenceRule": _isRecurrence! &
                                        (_freq == "DAILY")
                                    ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count'
                                    : (_isRecurrence! & (_freq == "WEEKLY")
                                        ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYDAY=$_byDay'
                                        : (_isRecurrence! & (_freq == "MONTHLY")
                                            ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYMONTHDAY=${_startDate!.day}'
                                            : 'FREQ=DAILY;INTERVAL=1;COUNT=1'))
                              });

                              _events!.appointments
                                  ?.remove(_selectedAppointment);
                              _events!.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[]..add(_selectedAppointment!));

                              if (!notification) {
                                DataSnapshot removeNot =
                                    await _updateRef.child("notIDs").get();

                                if (removeNot.exists) {
                                  for (var id in removeNot.children) {
                                    if (id.exists) {
                                      
                                      await NotificationService()
                                          .cancelSpecificNotifications(
                                              (id.value as Map)["ID"]);
                                    }
                                  }
                                }
                              } else {
                                _calendarRef
                                    .child(key!)
                                    .child("notIDs")
                                    .remove();
                                if (_freq == 'WEEKLY') {
                                  DateTime? finalNotification;
                                  final selectedNoti = _byDay!.split(',');
                                  final Map<String, int> daysNames = {
                                    'MO': 1,
                                    'TU': 2,
                                    'WE': 3,
                                    'TH': 4,
                                    'FR': 5,
                                    'SA': 6,
                                    'SU': 7,
                                  };

                                  final nextDays = selectedNoti.map((dia) {
                                    return daysNames[dia] ??
                                        dia; // Uses the full name if it is available, otherwise leave the abbreviation
                                  });

                                  String startTimeFormatted = '';
                                  String endTimeFormatted = '';
                                  int notID;
                                  
                                  //Sets a appointment's reminder for the days that have been choosen
                                  nextDays.forEach((element) {
                                    if ((element as int) <
                                        _startDate!.weekday) {
                                      
                                      //For the case in which a day is less than the current day
                                      element += 7;
                                      finalNotification = _startDate;
                                    }
                                    
                                    if (_startDate!.weekday == element) {
                                      notID = generateUniqueId();
                                      _calendarRef
                                          .child(key!)
                                          .child("notIDs")
                                          .child("$notID")
                                          .set({
                                        "Dia": _startDate!.weekday,
                                        "ID": notID,
                                      });

                                      //notification will be set 10 minutes before to remind the user
                                      finalNotification = _startDate!
                                          .add(const Duration(minutes: -10));
                                      
                                      //formats start and finash hour and minutes 
                                      startTimeFormatted =
                                          "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
                                      endTimeFormatted =
                                          "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";
                                      
                                      //Sets the notification 
                                      NotificationService()
                                          .periodicWeeklyNotification(
                                              id:
                                                  notID, 
                                              title: '¡Recuerda!',
                                              body:
                                                  "$_subject de $startTimeFormatted a $endTimeFormatted",
                                              scheduledNoti:
                                                  finalNotification!);
                                    } else {
                                      var diff = getDiff(
                                          _startDate!.weekday, element as int);

                                      notID = generateUniqueId();
                                      _calendarRef
                                          .child(key!)
                                          .child("notIDs")
                                          .child("$notID")
                                          .set({
                                        "Dia": element,
                                        "ID": notID,
                                      });

                                      DateTime aux = finalNotification!
                                          .add(Duration(days: diff));
                                      startTimeFormatted =
                                          "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
                                      endTimeFormatted =
                                          "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";
                                      NotificationService()
                                          .periodicWeeklyNotification(
                                              id: notID,
                                              title: '¡Recuerda!',
                                              body:
                                                  "$_subject de $startTimeFormatted a $endTimeFormatted",
                                              scheduledNoti: aux);
                                    }
                                  });
                                } else if (_freq == 'DAILY') {
                                  int notID = generateUniqueId();
                                  _calendarRef
                                      .child(key!)
                                      .child("notIDs")
                                      .child("$notID")
                                      .set({
                                    "Dia": _startDate!.weekday,
                                    "ID": notID,
                                  });

                                  var programedNoti =
                                      _startDate!.add(const Duration(minutes: -10));
                                  String startTimeFormatted =
                                      "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
                                  String endTimeFormatted =
                                      "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";

                                  NotificationService().periodicDailyNotification(
                                      id: notID,
                                      title: '¡Recuerda!',
                                      body:
                                          "$_subject de $startTimeFormatted a $endTimeFormatted",
                                      scheduledNoti: programedNoti);
                                }
                              }
                            } else {
                              meetings.add(Meeting(
                                  from: _startDate!,
                                  to: _endDate!,
                                  background: _colorCollection![
                                      _selectedColorIndex], //* COMPROBAR */
                                  startTimeZone: _selectedTimeZoneIndex == 0
                                      ? ''
                                      : _timeZoneCollection![
                                          _selectedTimeZoneIndex],
                                  endTimeZone: _selectedTimeZoneIndex == 0
                                      ? ''
                                      : _timeZoneCollection![
                                          _selectedTimeZoneIndex],
                                  description: _notes,
                                  isAllDay: _isAllDay!,
                                  eventName:
                                      _subject == '' ? 'SIN TITULO' : _subject,
                                  recurrenceRule: _isRecurrence! &
                                          (_freq == "DAILY")
                                      ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count'
                                      : (_isRecurrence! & (_freq == "WEEKLY")
                                          ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYDAY=$_byDay'
                                          : (_isRecurrence! &
                                                  (_freq == "MONTHLY")
                                              ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYMONTHDAY=${_startDate!.day}'
                                              : 'FREQ=DAILY;INTERVAL=1;COUNT=1'))));

                              key = _calendarRef.push().key!;

                              _calendarRef.child(key!).set({
                                "Key": key,
                                "StartTime": DateFormat('dd/MM/yyyy HH:mm:ss')
                                    .format(_startDate!),
                                "EndTime": DateFormat('dd/MM/yyyy HH:mm:ss')
                                    .format(_endDate!),
                                "Subject": _subject,
                                "Notification": notification,
                                "Color": _selectedColorIndex,
                                "isAllDay": _isAllDay,
                                "Description": _notes,
                                "recurrenceRule": _isRecurrence! &
                                        (_freq == "DAILY")
                                    ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count'
                                    : (_isRecurrence! & (_freq == "WEEKLY")
                                        ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYDAY=$_byDay'
                                        : (_isRecurrence! & (_freq == "MONTHLY")
                                            ? 'FREQ=$_freq;INTERVAL=$_interval;COUNT=$_count;BYMONTHDAY=${_startDate!.day}'
                                            : 'FREQ=DAILY;INTERVAL=1;COUNT=1')),
                              }).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('AÑADIDO CORRECTAMENTE')));
                              }).catchError((onError) {
                                print(onError);
                              });
                              _events?.appointments?.add(meetings[0]);

                              _events?.notifyListeners(
                                  CalendarDataSourceAction.add, meetings);
                              _selectedAppointment = null;

                              if (notification) {
                                if (_freq == 'WEEKLY') {
                                  DateTime? finalNotification;
                                  final selectedNoti = _byDay!.split(',');
                                  final Map<String, int> daysNames = {
                                    'MO': 1,
                                    'TU': 2,
                                    'WE': 3,
                                    'TH': 4,
                                    'FR': 5,
                                    'SA': 6,
                                    'SU': 7,
                                  };

                                  final nextDays = selectedNoti.map((dia) {
                                    return daysNames[dia] ??
                                        dia; // Uses the full name if it is available, otherwise leave the abbreviation
                                  });

                                  String startTimeFormatted = '';
                                  String endTimeFormatted = '';
                                  int notID;

                                  nextDays.forEach((element) {
                                    if ((element as int) <
                                        _startDate!.weekday) {
                                      
                                      //For the case in which a day is less than the current day
                                      element += 7;
                                      finalNotification = _startDate;
                                    }
                                   
                                    if (_startDate!.weekday == element) {
                                      notID = generateUniqueId();
                                      _calendarRef
                                          .child(key!)
                                          .child("notIDs")
                                          .child("$notID")
                                          .set({
                                        "Dia": _startDate!.weekday,
                                        "ID": notID,
                                      });

                                      finalNotification = _startDate!
                                          .add(const Duration(minutes: -10));

                                      startTimeFormatted =
                                          "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
                                      endTimeFormatted =
                                          "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";

                                      NotificationService()
                                          .periodicWeeklyNotification(
                                              id:
                                                  notID, 
                                              title: '¡Recuerda!',
                                              body:
                                                  "$_subject de $startTimeFormatted a $endTimeFormatted",
                                              scheduledNoti:
                                                  finalNotification!);
                                    } else {
                                      var diff = getDiff(
                                          _startDate!.weekday, element as int);

                                      notID = generateUniqueId();
                                      //Saves in the database the notification Ids
                                      _calendarRef
                                          .child(key!)
                                          .child("notIDs")
                                          .child("$notID")
                                          .set({
                                        "Dia": element,
                                        "ID": notID,
                                      });

                                      DateTime aux = finalNotification!
                                          .add(Duration(days: diff));
                                      startTimeFormatted =
                                          "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
                                      endTimeFormatted =
                                          "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";
                                      NotificationService()
                                          .periodicWeeklyNotification(
                                              id: notID,
                                              title: '¡Recuerda!',
                                              body:
                                                  "$_subject de $startTimeFormatted a $endTimeFormatted",
                                              scheduledNoti: aux);
                                    }
                                  });
                                } else if (_freq == 'DAILY') {
                                  int notID = generateUniqueId();
                                  _calendarRef
                                      .child(key!)
                                      .child("notIDs")
                                      .child("$notID")
                                      .set({
                                    "Dia": _startDate!.day,
                                    "ID": notID,
                                  });
                                  var programedNoti =
                                      _startDate!.add(const Duration(minutes: -10));
                                  String startTimeFormatted =
                                      "${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}";
                                  String endTimeFormatted =
                                      "${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}";

                                  NotificationService().periodicDailyNotification(
                                      id: notID,
                                      title: '¡Recuerda!',
                                      body:
                                          "$_subject de $startTimeFormatted a $endTimeFormatted",
                                      scheduledNoti: programedNoti);
                                }
                              }
                            }

                            Navigator.pop(context);
                          }),
                      const Text(
                        "GUARDAR",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), //* BORDES */
              child: Stack(
                children: <Widget>[_getAppointmentEditor(context)],
              ),
            ),
            //Trash button to remove the selected appointment
            floatingActionButton: _selectedAppointment == null
                ? const Text('')
                : Container(
                    width: 70,
                    height: 70,
                    child: FittedBox(
                      child: FloatingActionButton(
                        onPressed: () {
                          if (_selectedAppointment != null) {
                            _events!.appointments?.removeWhere((meeting) =>
                                meeting.from ==
                                    _selectedAppointment?.startTime &&
                                meeting.to == _selectedAppointment?.endTime);

                            key = _selectedAppointment!.location;

                            final userProvider = Provider.of<UserProvider>(
                                context,
                                listen: false);

                            final DatabaseReference _removeRef;

                            if (chosenCalendar == '1') {
                              _removeRef = FirebaseDatabase(
                                      databaseURL:
                                          "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
                                  .ref()
                                  .child("Usuarios2")
                                  .child("DatosUsuario")
                                  .child(userProvider.userKey)
                                  .child("CalendarData")
                                  .child(key!);
                            } else {
                              _removeRef = FirebaseDatabase(
                                    databaseURL:
                                        "https://prueba-76a0b-default-rtdb.europe-west1.firebasedatabase.app")
                                .ref()
                                .child("Usuarios2")
                                .child("CalendarData")
                                .child(key!);
                            }

                            _removeRef.remove();

                            _events?.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[]..add(_selectedAppointment!));
                            _selectedAppointment = null;
                            Navigator.pop(context);
                          }
                        },
                        backgroundColor: const Color.fromARGB(255, 43, 136, 148),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 30,
                            ),
                            Text(
                              "BORRAR",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            )
                          ],
                        ),
                      ),
                    ),
                  )));
  }
  
  ///Returns appointmet's title
  String getTitle() {
    return _subject.isEmpty ? 'New event' : 'Event details';
  }
}
