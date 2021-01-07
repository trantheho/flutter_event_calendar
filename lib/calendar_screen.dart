
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_event_calendar/crazy_expanded_calendar.dart';
import 'package:flutter_event_calendar/input_dialog.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

extension DateTimeExtension on DateTime {
  DateTime startOfDay() {
    if (this == null) return this;
    return DateTime(this.year, this.month, this.day);
  }

  String formatHHmm() {
    return DateFormat(DateFormat.HOUR24_MINUTE).format(this);
  }
}

class CalendarScreen extends StatefulWidget {

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>{
  CalendarController calendarController;
  Map<DateTime, List> _events;
  List<EventData> eventData = [];
  DateTime selectedDay = now;
  final eventInDay = BehaviorSubject<EventInWeek>();


  @override
  void initState() {
    calendarController = CalendarController();
    final _selectedDay = DateTime.now();
    _events = {
      _selectedDay.subtract(Duration(days: 30)): ['Event A0'],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): ['Event A2'],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3'],
      _selectedDay.subtract(Duration(days: 10)): ['Event A4'],
      _selectedDay.subtract(Duration(days: 4)): ['Event A5'],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6'],
      _selectedDay: ['Event A7'],
      _selectedDay.add(Duration(days: 1)): ['Event A8'],
      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9']).toList(),
      _selectedDay.add(Duration(days: 7)): ['Event A10'],
      _selectedDay.add(Duration(days: 11)): ['Event A11'],
      _selectedDay.add(Duration(days: 17)): ['Event A12'],
      _selectedDay.add(Duration(days: 22)): ['Event A13'],
      _selectedDay.add(Duration(days: 26)): ['Event A14'],
    };
    super.initState();
  }

  @override
  void dispose() {
    eventInDay.close();
    calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          padding: EdgeInsets.only(top: 200),
          child: SingleChildScrollView(
              child: StreamBuilder<EventInWeek>(
                  stream: eventInDay.stream,
                  initialData: EventInWeek(selectedDay: now, eventData: eventData),
                builder: (context, snapshot) {
                  final groupEvent = groupOverlappingEvents(
                      (snapshot.data == null && snapshot.data.eventData.isEmpty)
                          ? []
                          : snapshot.data.eventData.map((e) => e).toList());

                  return Stack(
                    children: [
                      Timeline(),

                      ...groupEvent.map((e) => EventGroupView(
                        selectDay: snapshot.data.selectedDay,
                        eventGroup: e,
                        eventCallback: (int index, double position, EventData event){

                        },
                      )).toList(),

                      CurrentTimeIndicator(day: DateTime.now()),
                    ],
                  );
                }
              )
          ),
        ),
        Column(
          children: [
            Container(
              color: Colors.blueGrey,
              padding: EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Row(
                children: [
                  Text(
                      'Event Calendar',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  Spacer(),
                  PopupMenuButton<int>(
                    offset: const Offset(0, -20),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                          value: 0,
                          child: Text('New Event')),
                    ],
                    onSelected: (value){
                      if(value == 0){
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) => InputDialogBuild(
                            title: 'Event',
                            onDataChange: (value) {
                              eventData.add(value);
                              eventInDay.add(
                                EventInWeek(
                                  selectedDay: selectedDay,
                                  eventData: eventData,
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: Icon(Icons.more_vert, color: Colors.white,),
                  )
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                )
              ),
              child: TableCalendar(
                calendarController: calendarController,
                events: _events,
                onDaySelected: (day, events, holiday){
                  selectedDay = day;
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: {CalendarFormat.week: 'Week', CalendarFormat.month: 'Month'},
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekdayStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  weekendStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  holidayStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  eventDayStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  selectedStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  selectedColor: Colors.orange,
                  todayStyle:  TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  todayColor: Colors.deepOrangeAccent.withOpacity(0.5),
                  highlightToday: true,
                  outsideWeekendStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.blueGrey),
                  outsideStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey),
                  markersColor: Colors.deepOrange,
                  bottomColor: Colors.white,
                  makerSize: 4.0,
                ),
                locale: 'vi',
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                  weekdayStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                headerStyle: HeaderStyle(
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white,),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white,),
                  centerHeaderTitle: true,
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  List<EventGroup> groupOverlappingEvents(List<EventData> events) {
    if(events.length == 0) return [];
    // Sort event by startDate increase.
    final sortedEvents = [...events];
    sortedEvents.sort(
          (event1, event2) => event1.startTime.compareTo(event2.startTime),
    );

    final eventGroups = [
      EventGroup(
        startDate: sortedEvents.first.startTime,
        endDate: sortedEvents.first.endTime,
        eventData: [sortedEvents.first],
      )
    ];

    var groupIndex = 0;

    for (int eventIndex = 1; eventIndex < sortedEvents.length; eventIndex++) {
      // Event overlap group event
      if (sortedEvents[eventIndex]
          .startTime
          .isBefore(eventGroups[groupIndex].endDate)) {
        eventGroups[groupIndex].eventData.add(sortedEvents[eventIndex]);

        // Update endDate of event group.
        if (sortedEvents[eventIndex]
            .endTime
            .isAfter(eventGroups[groupIndex].endDate)) {
          eventGroups[groupIndex].endDate = sortedEvents[eventIndex].endTime;
        }
      } else {
        eventGroups.add(EventGroup(
          startDate: sortedEvents[eventIndex].startTime,
          endDate: sortedEvents[eventIndex].endTime,
          eventData: [sortedEvents[eventIndex]],
        ));
        groupIndex++;
      }
    }

    return eventGroups;
  }

}

class EventInWeek{
  DateTime selectedDay;
  List<EventData> eventData;

  EventInWeek({this.selectedDay, this.eventData});
}

class EventGroup {
  DateTime startDate;
  DateTime endDate;
  List<EventData> eventData;

  EventGroup({
    this.startDate,
    this.endDate,
    this.eventData,
  });
}

class EventGroupView extends StatelessWidget {
  final DateTime selectDay;
  final EventGroup eventGroup;
  final Function(int index, double position, EventData event) eventCallback;

  EventGroupView({
    this.selectDay,
    this.eventGroup,
    this.eventCallback,
  });

  @override
  Widget build(BuildContext context) {
    if (eventGroup.eventData.isEmpty) return SizedBox();

    final groupPosition = _calculatePositionInTimeline(selectDay, eventGroup.startDate);

    return Positioned(
      left: 85.0,
      right: 0.0,
      top: groupPosition,
      height: _calculatePositionInTimeline(selectDay, eventGroup.endDate) - groupPosition,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(int index = 0; index<eventGroup.eventData.length; index++) Expanded(
            child: EventItem(
              selectDay: selectDay,
              groupPosition: groupPosition,
              event: eventGroup.eventData[index],
              index: index,
              eventCallback: eventGroup.eventData.length == 1 ? null : eventCallback,
            ),
          )
        ],
      ),
    );
  }
}

class EventItem extends StatefulWidget {
  final DateTime selectDay;
  final double groupPosition;
  final EventData event;
  final int index;
  final Function(int index, double position, EventData event) eventCallback;

  EventItem({
    this.selectDay,
    this.index,
    this.groupPosition,
    this.event,
    this.eventCallback,
  });

  @override
  _EventItemState createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animate;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..forward();
    animate = CurvedAnimation(parent: animationController, curve: Curves.linear);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final position = _calculatePositionInTimeline(widget.selectDay,widget.event.startTime);
    return GestureDetector(
      onTapDown: (value){
        widget.eventCallback?.call(widget.index, position, widget.event);
      },
      onTapUp: (value){
        widget.eventCallback?.call(-1, 0, null);
      },
      child: AnimatedBuilder(
        animation: animate,
        builder: (BuildContext context, Widget child) {
          return ScaleTransition(
            scale: animate,
            child: Container(
              margin: EdgeInsets.only(
                top: position - widget.groupPosition,
                left: 1.0,
                right: 1.0,
              ),
              height: _calculatePositionInTimeline(widget.selectDay,widget.event.endTime) - position,
              decoration: BoxDecoration(
                color: Colors.blueGrey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Text(
                      widget.event.name ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${widget.event.startTime.startOfDay()} - ${widget.event.endTime.startOfDay()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          );
        },
      ),
    );
  }
}

const oneHourItemHeight = 72.0;
const pixelPerSecond = oneHourItemHeight / Duration.secondsPerHour;

final now = DateTime.now().startOfDay();

class Timeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = List.generate(
      Duration.hoursPerDay + 1,
          (index) => index.toString(),
    );

    return Container(
      color: Colors.white,
      child: Column(
        children: hours
            .map(
              (hour) => SizedBox(
            height: oneHourItemHeight,
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Text(
                      '$hour:00',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class CurrentTimeIndicator extends StatefulWidget {
  final DateTime day;
  static const _size = 8.0;


  CurrentTimeIndicator({this.day});

  @override
  _CurrentTimeIndicatorState createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator>
    with SingleTickerProviderStateMixin {
  //https://dash-overflow.net/articles/why_vsync/
  Ticker _ticker;
  DateTime _startTime;
  DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _startTime = _currentTime = DateTime.now();

    _ticker = this.createTicker((elapsed) {
      final newTime = _startTime.add(elapsed);
      if (_currentTime.minute != newTime.minute) {
        setState(() => _currentTime = newTime);
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _currentPositionTime(_currentTime) -
          CurrentTimeIndicator._size / 2.0,
      left: 0.0,
      right: 0.0,
      child: Row(
        children: [
          SizedBox(width: 72),
          Container(
            width: CurrentTimeIndicator._size,
            height: CurrentTimeIndicator._size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(233, 163, 28, 1.0),
            ),
          ),
          Expanded(
            child: Container(
              color: Color.fromRGBO(233, 163, 28, 1.0),
              height: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}


double _calculatePositionInTimeline(DateTime selectDay, DateTime day) {

  final differentFromStartOfDay = day.difference(selectDay.startOfDay());

  var currentTimeTopPosition = differentFromStartOfDay.inSeconds * pixelPerSecond;

  if(day.startOfDay().isBefore(selectDay.startOfDay())){
    currentTimeTopPosition = 0;
  }
  else if(day.startOfDay().isAfter(selectDay.startOfDay())){
    currentTimeTopPosition = 24*60*60 * pixelPerSecond;
  }
  else{
    currentTimeTopPosition = differentFromStartOfDay.inSeconds * pixelPerSecond;
  }


  return oneHourItemHeight / 2.0 + currentTimeTopPosition;
}

double _currentPositionTime(DateTime dateTime) {
  final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);

  final differentFromStartOfDay = dateTime.difference(startOfDay);

  final currentTimeTopPosition = differentFromStartOfDay.inSeconds * pixelPerSecond;

  return oneHourItemHeight / 2.0 + currentTimeTopPosition;
}

