part of event_calendar;

///Widgets's list with the weekdays name
const List<Widget> days = <Widget>[
  Text('LUNES', style: TextStyle(color: Colors.black),),
  Text('MARTES', style: TextStyle(color: Colors.black),),
  Text('MIERCOLES', style: TextStyle(color: Colors.black),),
  Text('JUEVES', style: TextStyle(color: Colors.black),),
  Text('VIERNES', style: TextStyle(color: Colors.black),),
  Text('SABADO', style: TextStyle(color: Colors.black),),
  Text('DOMINGO', style: TextStyle(color: Colors.black),),
];

class _DayPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DayPickerState();
  }
}

class _DayPickerState extends State<_DayPicker> {
  final List<bool> _selectedDays = <bool>[];

  @override
  void initState() {
    super.initState();
    initializeDays();
  }

  ///Returns a boolean list with the selected days by the user
  void initializeDays() {
    _selectedDays.clear();
    for (int i = 0; i < days.length; i++) {
      if (i == _startDate!.weekday - 1) {
        _selectedDays.add(true);
      } else {
        _selectedDays.add(false);
      }
    }
  }

  ///Returns day's initials according to week day [day]
  String getByday(int day) {
    switch (day) {
      case 0:
        return _byDay = 'MO';
      case 1:
        return _byDay = 'TU';
      case 2:
        return _byDay = 'WE';
      case 3:
        return _byDay = 'TH';
      case 4:
        return _byDay = 'FR';
      case 5:
        return _byDay = 'SA';
      case 6:
        return _byDay = 'SU';
    }
    return '';
  }

  ///Returns day name according to day initials [day]
  String getDayName(String day) {
    switch (day) {
      case 'MO':
        return _byDay = 'LUNES';
      case 'TU':
        return _byDay = 'MARTES';
      case 'WE':
        return _byDay = 'MIERCOLES';
      case 'TH':
        return _byDay = 'JUEVES';
      case 'FR':
        return _byDay = 'VIERNES';
      case 'SA':
        return _byDay = 'SABADO';
      case 'SU':
        return _byDay = 'DOMINGO';
    }
    return '';
  }

  @override
  //builds the interface that allows user to pick the appointments's recurrence
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(5),
      backgroundColor: const Color.fromARGB(255, 245, 239, 216),
      content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [              
                    const Text("REPETIR CADA",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),),
                    DropdownButton(
                      value: _interval!,
                      items: _valueListInterval.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text('   $item'),
                        );
                      }).toList(),
                      onChanged: (item) {
                        setState(() {
                          _interval = item;
                        });
                      },
                    ),
                    //DropdownButton with different options of recurrence, return the appointment's frequency
                    DropdownButton(
                      value: _freqDayPicker!,
                      items: _valueListDayPickerFreq.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: (item == 'DAILY')
                              ? Text("${_interval == 1 ? 'DIA' : 'DIAS'}")
                              : ((item == 'WEEKLY')
                                  ? Text(
                                      "${_interval == 1 ? 'SEMANA' : 'SEMANAS'}")
                                  : const Text("MESES")),
                        );
                      }).toList(),
                      onChanged: (item) {
                        setState(() {
                          _freqDayPicker = item;
                        });
                      },
                    ),
                  ],
                ),
              ),
              //If appointment's frequency is weekly, it displays a list with the weekdays to allow user
              //choose which days it will repeat
              if (_freqDayPicker == 'WEEKLY')
                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 12, bottom: 12, right: 150),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "SE REPITE LOS DIAS",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      child: ToggleButtons(
                        direction: Axis.vertical,
                        borderWidth: 2,
                        borderColor: Colors.black,
                        selectedBorderColor: Colors.green,
                        fillColor: Color.fromARGB(255, 211, 218, 211),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: (int index) {
                          setState(() {
                            _selectedDays[index] = !_selectedDays[index];
                          });
                        },
                        isSelected: _selectedDays,
                        children: days,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        width: 170,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 174, 154, 217),
                            side: const BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid)
                          ),
                          onPressed: () {
                            byDayChain = '';
                            dayNames = '';

                            //for each day picked by the user, it builds a string with days's initials
                            //and another string with the days names 
                            for (int i = 0; i < days.length; i++) {
                              if (_selectedDays[i]) {
                                byDayChain += getByday(i) + ',';
                                dayNames += getDayName(getByday(i)) + ',';
                              }
                            }
                        
                            if (byDayChain.isNotEmpty) {
                              byDayChain =
                                  byDayChain.substring(0, byDayChain.length - 1);
                            }
                        
                            if (dayNames.isNotEmpty) {
                              dayNames =
                                  dayNames.substring(0, dayNames.length - 1);
                            }
                        
                            _freq = _freqDayPicker;
                            _byDay = byDayChain;

                            Future.delayed(const Duration(milliseconds: 100), () {
                              // When task is over, close the dialog
                              Navigator.pop(context);
                            });
                          },
                          child: const Text("CONFIRMAR", style: TextStyle(color: Colors.black),),
                        ),
                      ),
                    )
                  ],
                )
            ],
          )),
    );
  }
}
