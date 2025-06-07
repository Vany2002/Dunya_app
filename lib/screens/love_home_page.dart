import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/heart_widget.dart';

class LoveHomePage extends StatefulWidget {
  @override
  _LoveHomePageState createState() => _LoveHomePageState();
}

class _LoveHomePageState extends State<LoveHomePage> {
  DateTime? startDate;
  List<File> images = [];
  int currentImageIndex = 0;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysTogether = startDate != null ? DateTime.now().difference(startDate!).inDays : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Love App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HeartWidget(daysTogether: daysTogether),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Выберите дату начала отношений'),
            ),
            SizedBox(height: 20),
            if (images.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentImageIndex = (currentImageIndex + 1) % images.length;
                  });
                },
                child: Image.file(
                  images[currentImageIndex],
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Загрузить фото'),
            ),
          ],
        ),
      ),
    );
  }
}