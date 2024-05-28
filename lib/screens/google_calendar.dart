import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleAPI;
import 'package:http/io_client.dart' show IOClient, IOStreamedResponse;
import 'package:http/http.dart' show BaseRequest, Response;
import 'package:syncfusion_flutter_calendar/calendar.dart';

class GoogleApiService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[GoogleAPI.CalendarApi.calendarScope],
  );

  GoogleSignInAccount? _currentUser;

  GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> initializeGoogleSignIn() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
    });
    await _googleSignIn.signInSilently();
  }

  Future<List<GoogleAPI.Event>> getGoogleEventsData() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();


    final GoogleAPIClient httpClient =
        GoogleAPIClient(await googleUser!.authHeaders);
    
    final GoogleAPI.CalendarApi calendarApi = GoogleAPI.CalendarApi(httpClient);
    
    final GoogleAPI.Events calEvents = await calendarApi.events.list(
      "primary",
    );
    
    final List<GoogleAPI.Event> appointments = <GoogleAPI.Event>[];
    if (calEvents.items != null) {
      for (int i = 0; i < calEvents.items!.length; i++) {
        final GoogleAPI.Event event = calEvents.items![i];
        if (event.start == null) {
          continue;
        }
        appointments.add(event);
      }
    }
    
    return appointments;
  }

}

class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({required List<GoogleAPI.Event>? events}) {
    appointments = events;
  }

  @override
  DateTime getStartTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.start?.date ?? event.start!.dateTime!.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified!
        ? (event.start?.date ?? event.start!.dateTime!.toLocal())
        : (event.end?.date != null
            ? event.end!.date!.add(const Duration(days: -1))
            : event.end!.dateTime!.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments![index].location ?? '';
  }

  @override
  String getNotes(int index) {
    return appointments![index].description ?? '';
  }

  @override
  String getSubject(int index) {
    final GoogleAPI.Event event = appointments![index];
    return event.summary == null || event.summary!.isEmpty
        ? 'No Title'
        : event.summary!;
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url,
          headers: (headers != null ? (headers..addAll(_headers)) : headers));
}



//*FORMATO DE VISUALIZACION SI SE CARGA DESDE GOOGLE CALENDAR */


// Widget appointmentBuilder(BuildContext context,
//     CalendarAppointmentDetails calendarAppointmentDetails) {
//   final GoogleAPI.Event appointment = calendarAppointmentDetails.appointments.first;
//   print(calendarAppointmentDetails.bounds.height);
//   return Column(
//     children: [
//       // Container(
//       //   width: calendarAppointmentDetails.bounds.width,
//       //   height: calendarAppointmentDetails.bounds.height/2,
//       //   decoration: BoxDecoration(
//       //     color: appointment.color,
//       //     border: Border.all(color: Colors.black, width: 1),
//       //     borderRadius: const BorderRadius.only(
//       //         topLeft: Radius.circular(10), topRight: Radius.circular(10)),
//       //   ),
//       //   child: Column(
//       //     children: [
//       //       Text(
//       //         appointment.subject,
//       //         textAlign: TextAlign.center,
//       //         style: TextStyle(fontSize: 18),
//       //       ),
//       //       Text(
//       //         "Hora: " +
//       //             DateFormat('HH:mm').format(appointment.startTime) +
//       //             '-' +
//       //             DateFormat('HH:mm').format(appointment.endTime),
//       //         textAlign: TextAlign.center,
//       //         style: TextStyle(fontSize: 18),
//       //       )
//       //     ],
//       //   ),
//       // ),
//       Container(
//         width: calendarAppointmentDetails.bounds.width,
//         height: calendarAppointmentDetails.bounds.height,
//         decoration: BoxDecoration(
//           //color: appointment.color,
//           border: Border.all(color: Colors.black, width: 1),
//           borderRadius: const BorderRadius.all(Radius.circular(10)),
//         ),
//         child: (calendarAppointmentDetails.bounds.height > 50)
//             ? Column(
//                 children: [
//                   // Icono centrado verticalmente junto con el texto "Ubicacion"
//                   // const Padding(
//                   //   padding: EdgeInsets.only(left: 2),
//                   //   child: Column(
//                   //     mainAxisAlignment: MainAxisAlignment.center,
//                   //     children: [
//                   //       Icon(
//                   //         Icons.location_on_sharp,
//                   //       ),
//                   //       Text(
//                   //         "Ubicacion",
//                   //         style: TextStyle(fontSize: 15),
//                   //       ),
//                   //     ],
//                   //   ),
//                   // ),
//                   // const VerticalDivider(
//                   //   thickness: 1,
//                   //   color: Colors.black,
//                   // ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: (calendarAppointmentDetails.bounds.height > 116)
//                           ? Column(
//                               children: [
//                                 Text(
//                                   "appointment.subject",
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(fontSize: 18),
//                                 ),
//                                 Text(
//                                   "Hora: " ,//+
//                                       // DateFormat('HH:mm')
//                                       //     .format(appointment.startTime) +
//                                       // '-' +
//                                       // DateFormat('HH:mm')
//                                       //     .format(appointment.endTime),
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(fontSize: 18),
//                                 ),
//                                 const Divider(
//                                   thickness: 1,
//                                   color: Colors.black,
//                                 ),
//                               ],
//                             )
//                           : Padding(
//                               padding: const EdgeInsets.only(top: 5),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "appointment.subject",
//                                     textAlign: TextAlign.center,
//                                     style: (calendarAppointmentDetails
//                                                 .bounds.height >
//                                             80)
//                                         ? TextStyle(fontSize: 16)
//                                         : TextStyle(fontSize: 11),
//                                   ),
//                                   Text(
//                                     "     Hora: " ,//+
//                                         // DateFormat('HH:mm')
//                                         //     .format(appointment.startTime) +
//                                         // '-' +
//                                         // DateFormat('HH:mm')
//                                         //     .format(appointment.endTime),
//                                     textAlign: TextAlign.center,
//                                     style: (calendarAppointmentDetails
//                                                 .bounds.height >
//                                             80)
//                                         ? TextStyle(fontSize: 16)
//                                         : TextStyle(fontSize: 11),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                     ),
//                   ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                            " appointment.notes!.toString().toUpperCase()",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               )
//             : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                    " appointment.subjec",
//                     textAlign: TextAlign.center,
//                     style: (calendarAppointmentDetails.bounds.height > 25)
//                         ? TextStyle(fontSize: 16)
//                         : TextStyle(fontSize: 11),
//                   ),
//                   Text(
//                     "    Hora: ",//+
//                         // DateFormat('HH:mm').format(appointment.startTime) +
//                         // '-' +
//                         // DateFormat('HH:mm').format(appointment.endTime),
//                     textAlign: TextAlign.center,
//                     style: (calendarAppointmentDetails.bounds.height > 25)
//                         ? TextStyle(fontSize: 16)
//                         : TextStyle(fontSize: 11),
//                   )
//                 ],
//               ),
//       )
//     ],
//   );
// }

//* BODY DEL SFCALENDAR SI GOOGLE CALENDAR */

// body: FutureBuilder(
//           future: getGoogleEventsData(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             return Stack(
//               children: [
//                 SfCalendar(
//                       view: CalendarView.day,
//                       allowedViews: const [
//                         CalendarView.schedule,
//                         CalendarView.month,
//                         CalendarView.day,
//                       ],
//                       headerHeight: 40, //* 0 para quitar el header */
//                       headerDateFormat: ' ',
//                       controller: _controller,
//                       timeSlotViewSettings: const TimeSlotViewSettings(
//                           timeIntervalHeight: 201,
//                           timeRulerSize: 70,
//                           timeInterval: Duration(minutes: 60),
//                           timeFormat: 'HH:mm',
//                           dayFormat: 'EEEE',
//                           timeTextStyle: TextStyle(
//                             fontSize: 18,
//                             color: Colors.black,
//                           )),
//                       viewHeaderHeight: 0,
//                       onViewChanged: (ViewChangedDetails viewChangedDetails) {
//                         if (_controller!.view == CalendarView.day) {
//                           int dia = viewChangedDetails.visibleDates[0].weekday;
//                           String number = DateFormat('dd-MM-yyyy')
//                               .format(viewChangedDetails.visibleDates[0])
//                               .toString();
//                           switch (dia) {
//                             case 1:
//                               dayText = 'LUNES  $number';
//                             case 2:
//                               dayText = 'MARTES  $number';
//                             case 3:
//                               dayText = 'MIERCOLES  $number';
//                             case 4:
//                               dayText = 'JUEVES  $number';
//                             case 5:
//                               dayText = 'VIERNES  $number';
//                             case 6:
//                               dayText = 'SABADO  $number';
//                             case 7:
//                               dayText = 'DOMINGO  $number';
//                           }
//                         }
//                         SchedulerBinding.instance
//                             .addPostFrameCallback((duartion) {
//                           setState(() {});
//                         });
//                       },
//                       cellBorderColor: Colors.black,
//                       initialSelectedDate: DateTime(DateTime.now().year,
//                           DateTime.now().month, DateTime.now().day, 0, 0, 0),
//                       initialDisplayDate:
//                           DateTime.now().add(Duration(minutes: -60)),
//                       showCurrentTimeIndicator: true,
//                       //showTodayButton: true,
//                       dataSource: GoogleDataSource(events: snapshot.data),
//                       monthViewSettings: const MonthViewSettings(
//                         showAgenda: true,
//                         agendaItemHeight: 200,
//                       ),
//                       onTap: onCalendarTapped,
//                       backgroundColor: const Color.fromARGB(255, 245, 239, 216),
//                       scheduleViewMonthHeaderBuilder: monthBuilder,
//                       scheduleViewSettings: const ScheduleViewSettings(
//                         appointmentItemHeight: 200,
//                         hideEmptyScheduleWeek: true,
//                         dayHeaderSettings: DayHeaderSettings(
//                             dayFormat: 'EEEE',
//                             width: 70,
//                             dayTextStyle: TextStyle(
//                               color: Colors.black,
//                               fontSize: 12,
//                             ),
//                             dateTextStyle: TextStyle(
//                               fontSize: 25,
//                             )),
//                         weekHeaderSettings: WeekHeaderSettings(
//                           startDateFormat: 'MMMM dd',
//                           endDateFormat: 'MMMM dd, yyyy',
//                         ),
//                       ),
//                       appointmentBuilder: appointmentBuilder,
//                       todayTextStyle: const TextStyle(
//                         height: 1,
//                       ),
//                     ),
//                 snapshot.data != null
//                     ? Container()
//                     : const Center(
//                         child: CircularProgressIndicator(),
//                       )
//               ],
//             );
//           }),

//* PONER ENTRE EL FINAL DEL SCCAFOLD Y EL WIDGET(AL FINAL) */

//  @override
//   void dispose() {
//     if (_googleSignIn.currentUser != null) {
//       _googleSignIn.disconnect();
//       _googleSignIn.signOut();
//     }

//     super.dispose();
//   }
// }