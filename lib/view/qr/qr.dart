import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:open_settings/open_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants.dart';
import '../../controllers/permission.dart';
import '../../widgets/custom/custom_appbar.dart';
import '../../widgets/custom/custom_button.dart';

class QRPage extends StatefulWidget {
  final String data;
  final String name;
  const QRPage({required this.data, required this.name, super.key});

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  GlobalKey globalKey = GlobalKey();
  final ConnectivityResult _connectionStatusS = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  // late SwitchDetails? _switchDetails;

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    for (var result in results) {
      _initNetworkInfo(); // Process each result as needed
    }
  }

  String _connectionStatus = 'Unknown';
  final NetworkInfo _networkInfo = NetworkInfo();
  Future<void> _initNetworkInfo() async {
    String? wifiName,
        wifiBSSID,
        wifiIPv4,
        wifiIPv6,
        wifiGatewayIP,
        wifiBroadcast,
        wifiSubmask;

    try {
      await requestPermission(Permission.nearbyWifiDevices);
      // await requestPermission(Permission.locationWhenInUse);
    } catch (e) {
      print(e.toString());
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        // ignore: deprecated_member_use
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          // ignore: deprecated_member_use
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiName = await _networkInfo.getWifiName();
        } else {
          wifiName = await _networkInfo.getWifiName();
        }
      } else {
        wifiName = await _networkInfo.getWifiName();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi Name', error: e);
      wifiName = 'Failed to get Wifi Name';
    }

    try {
      if (!kIsWeb && Platform.isIOS) {
        // ignore: deprecated_member_use
        var status = await _networkInfo.getLocationServiceAuthorization();
        if (status == LocationAuthorizationStatus.notDetermined) {
          // ignore: deprecated_member_use
          status = await _networkInfo.requestLocationServiceAuthorization();
        }
        if (status == LocationAuthorizationStatus.authorizedAlways ||
            status == LocationAuthorizationStatus.authorizedWhenInUse) {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        } else {
          wifiBSSID = await _networkInfo.getWifiBSSID();
        }
      } else {
        wifiBSSID = await _networkInfo.getWifiBSSID();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi BSSID', error: e);
      wifiBSSID = 'Failed to get Wifi BSSID';
    }

    try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

    try {
      if (!Platform.isWindows) {
        wifiIPv6 = await _networkInfo.getWifiIPv6();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv6', error: e);
      wifiIPv6 = 'Failed to get Wifi IPv6';
    }

    try {
      if (!Platform.isWindows) {
        wifiSubmask = await _networkInfo.getWifiSubmask();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi submask address', error: e);
      wifiSubmask = 'Failed to get Wifi submask address';
    }

    try {
      if (!Platform.isWindows) {
        wifiBroadcast = await _networkInfo.getWifiBroadcast();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi broadcast', error: e);
      wifiBroadcast = 'Failed to get Wifi broadcast';
    }

    try {
      if (!Platform.isWindows) {
        wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      }
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi gateway address', error: e);
      wifiGatewayIP = 'Failed to get Wifi gateway address';
    }

    setState(() {
      _connectionStatus = wifiName!.toString();
      // 'Wifi BSSID: $wifiBSSID\n'
      // 'Wifi IPv4: $wifiIPv4\n'
      // 'Wifi IPv6: $wifiIPv6\n'
      // 'Wifi Broadcast: $wifiBroadcast\n'
      // 'Wifi Gateway: $wifiGatewayIP\n'
      // 'Wifi Submask: $wifiSubmask\n';
    });
  }

  Future<void> convertQrCodeToImage(
      BuildContext context, String data, String name) async {
    final boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    // Render QR code in a RepaintBoundary
    ui.Image qrImage = await boundary.toImage(pixelRatio: 3);

    // Define margin size and other drawing properties
    const double margin = 20.0;
    const double logoSize = 120.0; // Size of the logo
    const double textSize =
        40.0; // Adjust size based on the text height you expect

    // Calculate image size with margins
    final double qrImageWidth = qrImage.width.toDouble();
    final double qrImageHeight = qrImage.height.toDouble();
    final double imageWidth = qrImageWidth + 2 * margin;
    final double imageHeight =
        qrImageHeight + 3 * margin + logoSize + textSize; // Adjusted height

    // Create a new image with the margins
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, imageWidth, imageHeight));

    // Draw the QR code with margins
    canvas.drawRect(Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        Paint()..color = Colors.white);
    canvas.drawImageRect(
      qrImage,
      Rect.fromLTWH(0, 0, qrImageWidth, qrImageHeight),
      Rect.fromLTWH(margin, margin + logoSize + textSize + margin, qrImageWidth,
          qrImageHeight),
      Paint(),
    );

    // Draw the logo (assuming it's an asset) at the top center
    const logoImage = AssetImage('assets/images/BBT_Logo.png');
    final logo = await _loadImage(logoImage);
    final logoRect = Rect.fromLTWH(
      (imageWidth - logoSize) / 2, // Centered horizontally
      margin, // Positioned at the top with margin
      logoSize,
      logoSize,
    );
    canvas.drawImageRect(
      logo,
      Rect.fromLTWH(0, 0, logo.width.toDouble(), logo.height.toDouble()),
      logoRect,
      Paint(),
    );

    // Draw the name below the logo
    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: imageWidth,
    );

    final textOffset = Offset(
      (imageWidth - textPainter.width) / 2,
      logoRect.bottom + 5,
    );

    textPainter.paint(canvas, textOffset);

    // End recording and create the image
    ui.Image finalImage = await recorder
        .endRecording()
        .toImage(imageWidth.toInt(), imageHeight.toInt());

    // Convert the image to PNG format
    ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    final directory = (await getTemporaryDirectory()).path;
    File imgFile = File("$directory/qrCode.png");
    await imgFile.writeAsBytes(pngBytes);

    // Share the image
    await Share.shareFiles([imgFile.path],
        text:
            "Enjoy the ease of controlling your switches effortless operation, happy living!");
  }

  Future<ui.Image> _loadImage(ImageProvider provider) async {
    final Completer<ui.Image> completer = Completer();
    final ImageStream stream = provider.resolve(ImageConfiguration.empty);
    final ImageStreamListener listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info.image);
    });
    stream.addListener(listener);
    return completer.future;
  }

  Future _shareQRImage() async {
    final image = await QrPainter(
      data: widget.data,
      version: QrVersions.auto,
      gapless: false,
      color: Colors.white,
    ).toImageData(200.0, format: ImageByteFormat.png);
    const filename = 'qr_code.png';
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$filename').create();
    var bytes = image!.buffer.asUint8List();
    await file.writeAsBytes(bytes);
    final path = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'QR Code',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(heading: "QR CODE "),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RepaintBoundary(
                key: globalKey,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    QrImageView(
                      data: widget.data,
                      backgroundColor: whiteColour,
                      version: QrVersions.auto,
                      gapless: true,
                      foregroundColor: blackColour,
                      size: 200.0,
                    ),
                    // Positioned(
                    //   bottom: 10,
                    //   child: Container(
                    //     color: Colors.white.withOpacity(0.8),
                    //     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    //     child: Text(
                    //       widget.name,
                    //       style: const TextStyle(
                    //         color: Colors.black,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  convertQrCodeToImage(context, widget.data, widget.name);
                },
                child: Text(
                  "Share",
                  style: TextStyle(color: appBarColour),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Align(
                alignment: AlignmentDirectional(0, 0),
                child: Text(
                  'WIFI is connected to Wifi Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Text(
                  _connectionStatus.toString(),
                  style: TextStyle(
                      color: appBarColour,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButton(
                text: "Open WIFI Settings",
                icon: Icons.wifi_find,
                onPressed: () {
                  OpenSettings.openWIFISetting();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
