import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class ApkDownloadInstall extends StatefulWidget {
  const ApkDownloadInstall({super.key});

  @override
  _ApkDownloadInstallState createState() => _ApkDownloadInstallState();
}

class _ApkDownloadInstallState extends State<ApkDownloadInstall> {
  final String apkUrl = 'https://d2og5lryw1ajtt.cloudfront.net/APK/cataLystBuild6.apk';  // Replace with your APK download URL
  final String apkFileName = 'my_app';

  // Function to download APK file
  Future<void> downloadApk() async {
    // Request permission for storage
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final response = await http.get(Uri.parse(apkUrl));
        final dir = await getExternalStorageDirectory();
        final file = File('${dir!.path}/$apkFileName.apk');
        await file.writeAsBytes(response.bodyBytes);
        debugPrint('APK downloaded to ${file.path}');

        // Call install method after download
        await installApk(file.path);
      } catch (e) {
        debugPrint('Error downloading APK: $e');
      }
    } else {
      debugPrint("Storage permission denied");
    }
  }
  Future<void> installApk(String apkFilePath) async {
    // Request permissions
    if (await Permission.storage.request().isGranted &&
        await Permission.requestInstallPackages.request().isGranted) {
      try {
        if (await File(apkFilePath).exists()) {
          // Open the APK to install
          final result = await OpenFile.open(apkFilePath);
          if (result.type == ResultType.done) {
            print("APK installation started");
          } else {
            print("Failed to install APK: ${result.message}");
          }
        } else {
          print("APK file not found at: $apkFilePath");
        }
      } catch (e) {
        print("Error installing APK: $e");
      }
    } else {
      print("Permission denied to install APK");
    }
  }
  // Function to install APK file
  // Future<void> installApk(String filePath) async {
  //   try {
  //     // Open the APK file to trigger installation
  //     await OpenFile.open(filePath);
  //   } catch (e) {
  //     debugPrint("Error installing APK: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APK Downloader and Installer')),
      body: Center(
        child: ElevatedButton(
          onPressed: downloadApk,
          child: const Text('Download and Install APK'),
        ),
      ),
    );
  }
}
