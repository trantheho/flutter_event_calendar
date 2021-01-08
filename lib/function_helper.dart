import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:esys_flutter_share/esys_flutter_share.dart' as share;
import 'package:flutter/material.dart';

class FunctionHelper{
  GoogleMapController googleMapController;
  static const int imageMaxSize = 2000000;


  /// resize file
  static Future<File> resizeFile(File file) async {
    File newFile = file;
    while(await newFile.length() > imageMaxSize){
      var decodedImage = await decodeImageFromList(newFile.readAsBytesSync());
      img.Image imageTemp = img.decodeImage(file.readAsBytesSync());
      img.Image resizedImg = img.copyResize(imageTemp, width: decodedImage.width~/2, height: decodedImage.height~/2);
      newFile = file..writeAsBytesSync(img.encodePng(resizedImg));
    }
    return newFile;
  }

  /// set status bar style overlay ui
  static SystemUiOverlayStyle statusBarOverlayUI(Brightness androidBrightness){
    SystemUiOverlayStyle statusBarStyle;
    if(Platform.isIOS)
      statusBarStyle = (androidBrightness == Brightness.light) ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    if(Platform.isAndroid){
      statusBarStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: androidBrightness ?? Brightness.light);
    }
    return statusBarStyle;
  }

  /// Navigate push with callback
  static void navigatePush(context, String screenName, Widget screen, [Function(Object) callback]) {
    if (context == null) return null;
    Navigator.push(context,
        CupertinoPageRoute(builder: (context) =>
        screen,
          settings: RouteSettings(name: screenName),
        )
    ).then((data) {
      if (data != null && callback != null) {
        callback(data);
      }
    });
  }

  /// Navigate replace
  static void navigateReplace(context, String screenName, Widget screen, {Object result}) {
    if (context == null) return;
    Navigator.pushReplacement(context,
        CupertinoPageRoute(builder: (context) =>
        screen,
          settings: RouteSettings(name: screenName),
        ),
        result: result);
  }

  /// Pop to screen in stack
  static void popTo(context, String screenName, Widget screen) {
    if (context == null) return;
//    Navigator.popUntil(context, ModalRoute.withName(screenName));
    Navigator.of(context).popUntil((route) {
      return route.settings.name == screenName;
    });
  }

  /// Navigate push and remove previous stack
  static void navigatePushAndRemoveUltil(context, String screenName, Widget screen) {
    if (context == null) return;
    Navigator.pushAndRemoveUntil(context,
        CupertinoPageRoute(builder: (context) =>
        screen,
          settings: RouteSettings(name: screenName),
        ), (Route<dynamic> route) => false);
  }

  /// Pop to first screen in stack
  static void popToFirst(context) {
    if (context == null) return;
    Navigator.of(context).popUntil((route) {
      return route.isFirst;
    });
  }

  /// screenshot with map
  Future<void> screenshot(GlobalKey key) async {
    //loadingScreenShot.push(true);

    await Future.delayed(Duration(milliseconds: 20));

    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    final Uint8List  mapByte = await googleMapController.takeSnapshot();

    final mapImg = img.decodeImage(mapByte);

    final dataImg = img.decodeImage(pngBytes);

    final scale = dataImg.width/mapImg.width;

    final scaleMap = img.copyResize(mapImg, width: (mapImg.width * scale).toInt(), height: (mapImg.height * scale).toInt());

    final mergedImage = img.Image(dataImg.width, dataImg.height);

    img.copyInto(mergedImage, dataImg, blend: false);
    img.copyInto(mergedImage, scaleMap, blend: false);

    final fullImg = img.encodePng(mergedImage);

    await share.Share.file('Hunting Journal', 'screenshot.jpg', fullImg, 'image/jpg');

    //loadingScreenShot.push(false);

    /* Directory directory = await getApplicationDocumentsDirectory();

    print(directory);

    File imgFile = new File('$directory/screenshot.png');

    print(imgFile.path);

    try{

      imgFile.writeAsBytesSync(fullImg);

    } catch (error){
      print(error);
    }

    await Share.shareFiles([imgFile.path],
        mimeTypes: ['image/png'], text: 'my hunt', subject: 'Hunting Journal');*/

    /*AppHelper.navigatePush(key.currentContext, AppScreenName.empty, EmptyScreen(
      title: 'test image',
      imageByte: fullImg,
    ));*/

  }



}

/// Log utils
class Logging {
  static int tet;

  static void log(dynamic data) {
    if (!kReleaseMode) print(data);
  }
}