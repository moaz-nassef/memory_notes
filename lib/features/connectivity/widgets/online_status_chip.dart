import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:memory_notes/features/connectivity/cubit/connectivity_state.dart';

/// A little pill that shows whether the app is online — with jokes,
/// because a plain "Offline" label is sad and boring.
class OnlineStatusChip extends StatefulWidget {
  const OnlineStatusChip({super.key});

  @override
  State<OnlineStatusChip> createState() => _OnlineStatusChipState();
}

class _OnlineStatusChipState extends State<OnlineStatusChip> {
  static const List<String> _onlineJokes = [
    'Online. The hamster is running.',
    'Connected to the mothership.',
    'Online. Wifi earned its keep.',
    'Internet: still a thing.',
  ];

  static const List<String> _offlineJokes = [
    "Offline. It's 1995 again.",
    'Offline. The hamster is napping.',
    'Ninja mode: invisible to wifi.',
    'Wifi went out for milk...',
    'Offline. Pigeon mail only.',
    'No internet. Notes still love you.',
  ];

  static const Duration _jokeInterval = Duration(seconds: 4);

  final Random _random = Random();
  Timer? _jokeTimer;
  String _currentJoke = _onlineJokes.first;

  @override
  void initState() {
    super.initState();
    _jokeTimer = Timer.periodic(_jokeInterval, (_) => _nextJoke());
  }

  void _nextJoke() {
    if (!mounted) return;
    final state = context.read<ConnectivityCubit>().state;
    final jokes = state is ConnectivityOffline ? _offlineJokes : _onlineJokes;
    String next;
    do {
      next = jokes[_random.nextInt(jokes.length)];
    } while (next == _currentJoke && jokes.length > 1);
    setState(() => _currentJoke = next);
  }

  @override
  void dispose() {
    _jokeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConnectivityCubit, ConnectivityState>(
      // Flip to a fresh joke the moment the status changes.
      listener: (context, state) => _nextJoke(),
      builder: (context, state) {
        final isChecking = state is ConnectivityChecking;

        final color = switch (state) {
          ConnectivityChecking() => Colors.blueGrey,
          ConnectivityOnline() => const Color(0xFF2ECC71),
          ConnectivityOffline() => const Color(0xFFE74C3C),
        };

        final icon = switch (state) {
          ConnectivityChecking() => Icons.wifi_find_rounded,
          ConnectivityOnline() => Icons.wifi_rounded,
          ConnectivityOffline() => Icons.wifi_off_rounded,
        };

        final text = isChecking ? 'Poking the internet...' : _currentJoke;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(icon, key: ValueKey(icon), size: 16, color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    text,
                    key: ValueKey(text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
