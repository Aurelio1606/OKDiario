part of event_calendar;

const List<Widget> days = <Widget>[
  Text('LUNES', style: TextStyle(color: Colors.black),),
  Text('MARTES', style: TextStyle(color: Colors.black),),
  Text('MIERCOLES', style: TextStyle(color: Colors.black),),
  Text('JUEVES', style: TextStyle(color: Colors.black),),
  Text('VIERNES', style: TextStyle(color: Colors.black),),
  Text('SABADO', style: TextStyle(color: Colors.black),),
  Text('DOMINGO', style: TextStyle(color: Colors.black),),
];

// void initializaDays(){
//   for(int i = 0; i < days.length; i++){
//     if(i == _selectedAppointment!.startTime.day){
//       _selectedDays[i] = true;
//     }else{
//       _selectedDays[i] = false;
//     }
//   }
// }

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
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(5),
      backgroundColor: Color.fromARGB(255, 245, 239, 216),
      content: Container(
          
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // DropdownButton(
                    //   value: _count!,
                    //   items: _valueListCount.map((item) {
                    //     return DropdownMenuItem(
                    //       value: item,
                    //       child: Text('$item'),
                    //     );
                    //   }).toList(),
                    //   onChanged: (item) {
                    //     setState(() {
                    //       _count = item;
                    //     });
                    //   },
                    // ),
                    Text("REPETIR CADA",
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
                                  : Text("MESES")),
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
              if (_freqDayPicker == 'WEEKLY')
                Column(
                  children: [
                    const Padding(
                      padding: const EdgeInsets.only(
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
                            backgroundColor: Color.fromARGB(255, 174, 154, 217),
                            side: BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid)
                          ),
                          onPressed: () {
                            byDayChain = '';
                            dayNames = '';
                        
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
                        
                            print(byDayChain);
                            print(dayNames);
                        
                            Future.delayed(const Duration(milliseconds: 100), () {
                              // When task is over, close the dialog
                              Navigator.pop(context);
                            });
                          },
                          child: Text("CONFIRMAR", style: TextStyle(color: Colors.black),),
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
