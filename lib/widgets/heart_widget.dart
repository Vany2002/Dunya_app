import 'package:flutter/material.dart';

class HeartWidget extends StatefulWidget {
  final int daysTogether;
  final String? showPhrase;

  HeartWidget({required this.daysTogether, this.showPhrase});

  @override
  _HeartWidgetState createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant HeartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showPhrase != null && oldWidget.showPhrase != widget.showPhrase) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScaleTransition(
          scale: _scaleAnim,
          child: Icon(
            Icons.favorite,
            color: Colors.red.shade700,
            size: 100,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: Colors.redAccent.shade100,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Дней вместе: ${widget.daysTogether}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 400),
          child: widget.showPhrase != null
              ? Text(
            widget.showPhrase!,
            key: ValueKey<String>(widget.showPhrase!),
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Colors.pink.shade700,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.pinkAccent.shade100,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          )
              : SizedBox.shrink(),
        ),
      ],
    );
  }
}