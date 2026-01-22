import 'package:flutter/material.dart';
import 'package:memory_notes/models/Note Model.dart';

class Header extends StatelessWidget {
  const Header({super.key, required this.notes});

  final List<NoteModel> notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'memorys ',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              Text(
                '${notes.length} notes',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 255, 247, 247),
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.search_rounded, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
