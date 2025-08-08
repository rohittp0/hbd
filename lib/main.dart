import 'dart:async';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const BirthdayApp());
}

class BirthdayApp extends StatelessWidget {
  const BirthdayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday',
      theme: ThemeData(useMaterial3: true),
      home: const BirthdayPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BirthdayPage extends StatefulWidget {
  const BirthdayPage({super.key});

  @override
  State<BirthdayPage> createState() => _BirthdayPageState();
}

class _BirthdayPageState extends State<BirthdayPage> {
  late ConfettiController _confetti;
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 10));

    // Start ticking once per second for countdown + same-day re-eval
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final isBirthday = (now.month == 8 && now.day == 8);

      if (isBirthday) {
        // Keep a small loop of bursts
        if (_confetti.state != ConfettiControllerState.playing) {
          _confetti.play();
        }
        setState(() {
          _timeLeft = Duration.zero;
        });
      } else {
        if (_confetti.state == ConfettiControllerState.playing) {
          _confetti.stop();
        }
        final target = _nextAug8From(now);
        setState(() {
          _timeLeft = target.difference(now);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _confetti.dispose();
    super.dispose();
  }

  static DateTime _nextAug8From(DateTime now) {
    final thisYearTarget = DateTime(now.year, 8, 8);
    if (now.isBefore(thisYearTarget)) {
      return thisYearTarget;
    }
    // If it's already Aug 8 or later, go to next year’s Aug 8
    return DateTime(now.year + 1, 8, 8);
  }

  String _format(Duration d) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    final secs = d.inSeconds % 60;
    return '${days}d ${hours}h ${mins}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isBirthday = (now.month == 8 && now.day == 8);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Replace with your own image path
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/birthday.png',
                        width: 260,
                        height: 260,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isBirthday ? 'Happy Birthday! 🎉' : 'Countdown to Aug 8',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (!isBirthday)
                      Text(
                        _format(_timeLeft),
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                    if (isBirthday)
                      const Text(
                        'Hope you have an awesome day!',
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),

            // Confetti (only matters on birthday)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: true,
                emissionFrequency: 0.08,
                numberOfParticles: 12,
                gravity: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
