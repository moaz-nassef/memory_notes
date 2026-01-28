import 'dart:ui';

import 'package:flutter/material.dart';

class TopBarAddnote extends StatelessWidget {
  TopBarAddnote({
    super.key,
    required this.saveNote,
    required this.selectedColor,
  });
  Color selectedColor = Color(0xFF667EEA);
  final VoidCallback saveNote;

  @override
  Widget build(BuildContext context) {
    return // Top Bar - Floating Glass
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: selectedColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
                Spacer(),
                Text(
                  'ملاحظة جديدة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.check_circle_rounded),
                  color: Color(0xFF2ECC71),
                  iconSize: 28,
                  onPressed: saveNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
