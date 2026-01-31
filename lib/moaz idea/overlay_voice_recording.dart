
import 'package:flutter/material.dart';

if (showVoiceOverlay) Positioned.fill(child: _buildVoiceOverlay()),


  Widget _buildVoiceOverlay() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Transform.translate(
            offset: dragOffset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isRecording ? Icons.mic : Icons.mic_none_rounded,
                      color: Colors.purple,
                      size: 56,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  isRecording
                      ? 'جارٍ التسجيل • ${recordingSeconds}s'
                      : 'اضغط مطولاً للتسجيل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.delete, color: Colors.redAccent),
                        SizedBox(height: 6),
                        Text(
                          'اسحب لليمين للحذف',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(width: 40),
                    Column(
                      children: [
                        Icon(Icons.send, color: Colors.greenAccent),
                        SizedBox(height: 6),
                        Text(
                          'اسحب للأعلى للإرسال',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
