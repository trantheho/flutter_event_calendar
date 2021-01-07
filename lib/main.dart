import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_event_calendar/calendar_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {
  final globalScaffoldKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale(ui.window.locale?.languageCode),
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      navigatorKey: globalScaffoldKey,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: Colors.blueGrey,
          body: SafeArea(
            bottom: false,
              child: CalendarScreen(
              )
          ),
      ),
    );
  }
}
