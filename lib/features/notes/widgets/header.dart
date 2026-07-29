import 'package:flutter/material.dart';
import 'package:memory_notes/features/connectivity/widgets/online_status_chip.dart';
import 'package:memory_notes/shared/effects/animated_gradient_text.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.noteCount});

  final int noteCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedGradientText(
                'memorys',
                style:
                    Theme.of(context).textTheme.headlineMedium ??
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                '$noteCount notes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          const Expanded(child: OnlineStatusChip()),
          IconButton(
            icon: Icon(Icons.search_rounded, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
