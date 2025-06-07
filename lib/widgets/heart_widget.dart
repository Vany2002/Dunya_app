import 'package:flutter/material.dart';

class HeartWidget extends StatelessWidget {
  final int daysTogether;

  HeartWidget({required this.daysTogether});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.favorite,
          color: Colors.red,
          size: 100,
        ),
        Text(
          'Дней вместе: $daysTogether',
          style: TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}