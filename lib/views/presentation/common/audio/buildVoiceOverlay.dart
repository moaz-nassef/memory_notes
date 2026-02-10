import 'dart:ui';
import 'package:flutter/material.dart';

class buildVoiceOverlay extends StatelessWidget {
  const buildVoiceOverlay({
    super.key,
    required this.dragOffset,
    required AnimationController pulseController,
    required this.recordingSeconds,
  }) : pulseController = pulseController;

  final Offset dragOffset;
  final AnimationController pulseController;
  final int recordingSeconds;

  @override
  Widget build(BuildContext context) {
    final isNearDelete = dragOffset.dx < -50;
    final isNearSend = dragOffset.dy < -50;

    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Stack(
        children: [
          Positioned(
            bottom: 40,
            right: 30,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                final scale = 1.0 + (pulseController.value * 0.15);

                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.6),
                      blurRadius: 25 + (15 * pulseController.value),
                      spreadRadius: 3 + (5 * pulseController.value),
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 28),
              ),
            ),
          ),

          // 🎤 Recording Card
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 25,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Red dot
                        AnimatedBuilder(
                          animation: pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(
                                      0.6 * (1 - pulseController.value),
                                    ),
                                    blurRadius: 10 * pulseController.value,
                                    spreadRadius: 3 * pulseController.value,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 14),
                        Text(
                          '0:${recordingSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Waveform
                        ...List.generate(6, (index) {
                          return AnimatedBuilder(
                            animation: pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 3,
                                height:
                                    15 +
                                    (10 * ((index % 3) + 1)) *
                                        (0.5 + 0.5 * pulseController.value),
                                margin: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.purple, Colors.deepPurple],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 🗑️ Delete Zone
          Positioned(
            right: 30,

            bottom: 40,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: isNearDelete ? 210 : 180,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    isNearDelete
                        ? Colors.red.withOpacity(0.9)
                        : Colors.red.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isNearDelete ? 16 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          isNearDelete ? 1.0 : 0.9,
                        ),
                        shape: BoxShape.circle,
                        boxShadow:
                            isNearDelete
                                ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: isNearDelete ? 32 : 28,
                      ),
                    ),
                    SizedBox(width: 12),
                    if (isNearDelete) ...[
                      Text(
                        'حذف',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ✅ Send Zone
          Positioned(
            bottom: 110,
            right: 30,

            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 70,
              height: isNearSend ? 210 : 180,
              // child: ClipRRect(
              // borderRadius: BorderRadius.only(
              //   bottomLeft: Radius.circular(50),
              //   bottomRight: Radius.circular(50),
              // ),
              // child: BackdropFilter(
              // filter: ImageFilter.blur(
              // sigmaX: isNearSend ? 20 : 15,

              // sigmaY: isNearSend ? 20 : 15,
              // ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.transparent,
                      Colors.green.withOpacity(isNearSend ? 0.9 : 0.6),
                    ],
                  ),

                  // border: Border.all(
                  //   color: Colors.white.withOpacity(0.1),
                  //   width: 1,
                  // ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isNearSend ? 16 : 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isNearSend ? 1.0 : 0.9),
                        shape: BoxShape.circle,
                        boxShadow:
                            isNearSend
                                ? [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                                : null,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.green,
                        size: isNearSend ? 32 : 28,
                      ),
                    ),
                    SizedBox(height: 16),
                    Icon(
                      Icons.keyboard_double_arrow_up_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 36,
                    ),
                    if (isNearSend) ...[
                      SizedBox(height: 12),
                      Text(
                        'إرسال',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                // ),
              ),

              // ),
            ),
          ),
        ],
      ),
    );
  }
}
