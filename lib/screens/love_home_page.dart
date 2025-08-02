import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/heart_widget.dart';

class LoveHomePage extends StatefulWidget {
  final Function(Color) onThemeChange;
  final Color currentColor;
  final List<Color> availableColors;

  LoveHomePage({
    required this.onThemeChange,
    required this.currentColor,
    required this.availableColors,
  });

  @override
  _LoveHomePageState createState() => _LoveHomePageState();
}

class _LoveHomePageState extends State<LoveHomePage> {
  DateTime? startDate;
  List<File> images = [];
  int currentImageIndex = 0;

  final List<String> _lovePhrases = [
    'Люблю тебя',
    'Милая моя',
    'Ты — мое счастье',
    'Навсегда вместе',
    'Ты — мой свет',
  ];
  int _currentPhraseIndex = 0;
  String? _currentPhrase;

  static const String startDateKey = 'start_date';
  static const String imagesKey = 'images_paths';
  static const String currentImageIndexKey = 'current_image_index';
  static const String phraseIndexKey = 'phrase_index';

  @override
  void initState() {
    super.initState();
    _loadStartDate();
    _loadImagesAndSetIndex();
    _loadPhraseIndex();
  }

  Future<void> _loadStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(startDateKey);
    if (dateString != null) {
      setState(() {
        startDate = DateTime.parse(dateString);
      });
    }
  }

  Future<void> _saveStartDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(startDateKey, date.toIso8601String());
  }

  Future<void> _loadImagesAndSetIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? paths = prefs.getStringList(imagesKey);
    int savedIndex = prefs.getInt(currentImageIndexKey) ?? -1; // -1 если нет сохранённого

    List<File> loadedImages = [];
    if (paths != null) {
      for (var path in paths) {
        final file = File(path);
        if (await file.exists()) {
          loadedImages.add(file);
        }
      }
    }

    if (loadedImages.isEmpty) {
      savedIndex = 0;
    } else {
      // Увеличиваем индекс на 1 циклически
      savedIndex = (savedIndex + 1) % loadedImages.length;
      // Сохраняем обновлённый индекс
      await prefs.setInt(currentImageIndexKey, savedIndex);
    }

    setState(() {
      images = loadedImages;
      currentImageIndex = savedIndex;
    });
  }

  Future<void> _saveImages() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> paths = images.map((file) => file.path).toList();
    await prefs.setStringList(imagesKey, paths);

    if (currentImageIndex >= images.length) {
      currentImageIndex = images.isEmpty ? 0 : images.length - 1;
      await prefs.setInt(currentImageIndexKey, currentImageIndex);
    }
  }

  Future<void> _loadPhraseIndex() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt(phraseIndexKey);
    if (savedIndex != null) {
      setState(() {
        _currentPhraseIndex = savedIndex;
      });
    }
  }

  Future<void> _savePhraseIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(phraseIndexKey, index);
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
      await _saveStartDate(picked);
    }
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        images.add(file);
      });
      await _saveImages();
    }
  }

  void _removeImage(int index) async {
    setState(() {
      images.removeAt(index);
      if (currentImageIndex >= images.length) {
        currentImageIndex = images.isEmpty ? 0 : images.length - 1;
      }
    });
    await _saveImages();
  }

  void _nextImage() async {
    if (images.isEmpty) return;
    setState(() {
      currentImageIndex = (currentImageIndex + 1) % images.length;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(currentImageIndexKey, currentImageIndex);
  }

  void _onHeartTap() async {
    setState(() {
      _currentPhrase = _lovePhrases[_currentPhraseIndex];
      _currentPhraseIndex = (_currentPhraseIndex + 1) % _lovePhrases.length;
    });
    await _savePhraseIndex(_currentPhraseIndex);

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _currentPhrase = null;
      });
    });
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.availableColors.map((color) {
                bool isSelected = color.value == widget.currentColor.value;

                BoxDecoration decoration;
                if (color == Colors.white) {
                  decoration = BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  );
                } else {
                  decoration = BoxDecoration(shape: BoxShape.circle);
                }

                return GestureDetector(
                  onTap: () {
                    widget.onThemeChange(color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    decoration: decoration,
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 16,
                      child: isSelected
                          ? Icon(
                        Icons.check,
                        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                      )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysTogether = startDate != null ? DateTime.now().difference(startDate!).inDays : 0;

    // Цвет фона с небольшой прозрачностью для ярких цветов, белый без изменений
    Color backgroundColor;
    if (widget.currentColor == Colors.white) {
      backgroundColor = Colors.white;
    } else {
      backgroundColor = widget.currentColor.withOpacity(0.1);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Love App'),
        backgroundColor: widget.currentColor,
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            tooltip: 'Выбрать цвет темы',
            onPressed: _showThemePicker,
          )
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: _onHeartTap,
                  child: HeartWidget(
                    daysTogether: daysTogether,
                    showPhrase: _currentPhrase,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    startDate == null
                        ? 'Выберите дату начала отношений'
                        : 'Дата начала отношений: ${startDate!.toLocal().toString().split(' ')[0]} (нажмите, чтобы изменить)',
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(widget.currentColor),
                    foregroundColor: MaterialStateProperty.all(
                      widget.currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (images.isNotEmpty)
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _nextImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: AnimatedSwitcher(
                                duration: Duration(milliseconds: 600),
                                switchInCurve: Curves.easeIn,
                                switchOutCurve: Curves.easeOut,
                                child: Image.file(
                                  images[currentImageIndex],
                                  key: ValueKey<String>(images[currentImageIndex].path),
                                  width: 280,
                                  height: 280,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.delete, color: Colors.white, size: 22),
                              onPressed: () => _removeImage(currentImageIndex),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Загрузить фото'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(widget.currentColor),
                    foregroundColor: MaterialStateProperty.all(
                      widget.currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}