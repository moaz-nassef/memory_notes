import 'package:flutter/material.dart';
import 'dart:ui';

class VoiceRecordingOverlay extends StatefulWidget {
  const VoiceRecordingOverlay({super.key});

  @override
  State<VoiceRecordingOverlay> createState() => _VoiceRecordingOverlayState();
}

class _VoiceRecordingOverlayState extends State<VoiceRecordingOverlay>
    with TickerProviderStateMixin {
  bool isRecording = false;
  Offset micPosition = Offset(0, 0);
  bool isDragging = false;
  bool showDeleteZone = false;
  bool showSendZone = false;

  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse Animation للمايك
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Scale Animation للضغط
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      isRecording = true;
    });
    _scaleController.forward();
  }

  void _stopRecording() {
    setState(() {
      isRecording = false;
      isDragging = false;
      showDeleteZone = false;
      showSendZone = false;
    });
    _scaleController.reverse();
  }

  void _onDragUpdate(LongPressMoveUpdateDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(details.globalPosition);
    setState(() {
      micPosition = local;
      isDragging = true;

      // Check delete zone (right side)
      if (micPosition.dx > MediaQuery.of(context).size.width - 150) {
        showDeleteZone = true;
        showSendZone = false;
      }
      // Check send zone (top)
      else if (micPosition.dy < 150) {
        showSendZone = true;
        showDeleteZone = false;
      } else {
        showDeleteZone = false;
        showSendZone = false;
      }
    });
  }

  void _onDragEnd(LongPressEndDetails details) {
    if (showDeleteZone) {
      // حذف التسجيل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 12),
              Text('تم حذف التسجيل'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (showSendZone) {
      // إرسال التسجيل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('تم إرسال التسجيل ✅'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    _stopRecording();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic_none_rounded,
                  size: 100,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 20),
                Text(
                  'اضغط مطولاً على المايك للتسجيل',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Recording Overlay
          if (isRecording) _buildRecordingOverlay(),

          // Floating Mic Button
          Positioned(
            bottom: 30,
            right: 30,
            child: GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressMoveUpdate: isRecording ? _onDragUpdate : null,
              onLongPressEnd: isRecording ? _onDragEnd : null,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple, Colors.deepPurple],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(
                                  0.5 * (1 - _pulseController.value),
                                ),
                                blurRadius: 20 + (20 * _pulseController.value),
                                spreadRadius: 5 * _pulseController.value,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Stack(
        children: [
          // ✅ Delete Zone (Right - Horizontal)
          Positioned(
            right: 0,
            bottom: MediaQuery.of(context).size.height / 2 - 25,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: showDeleteZone ? 200 : 180,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    showDeleteZone
                        ? Colors.red.withOpacity(0.9)
                        : Colors.red.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: [0.3, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(showDeleteZone ? 14 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(
                          showDeleteZone ? 0.9 : 0.7,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: showDeleteZone ? 28 : 24,
                      ),
                    ),
                    if (showDeleteZone) ...[
                      SizedBox(width: 12),
                      Text(
                        'حذف',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ✅ Send Zone (Top - Vertical)
          Positioned(
            right: MediaQuery.of(context).size.width / 2 - 40,
            top: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 80,
              height: showSendZone ? 220 : 200,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: showSendZone ? 15 : 10,
                    sigmaY: showSendZone ? 15 : 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          showSendZone
                              ? Colors.green.withOpacity(0.7)
                              : Colors.green.withOpacity(0.4),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(showSendZone ? 14 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              showSendZone ? 0.9 : 0.7,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.green,
                            size: showSendZone ? 28 : 24,
                          ),
                        ),
                        SizedBox(height: 12),
                        Icon(
                          Icons.keyboard_double_arrow_up_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 32,
                        ),
                        if (showSendZone) ...[
                          SizedBox(height: 8),
                          Text(
                            'إرسال',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Recording Timer & Waveform
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '0:15',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(width: 16),
                        // Waveform
                        ...List.generate(
                          6,
                          (index) => Container(
                            width: 3,
                            height: 20 + (index % 3) * 10,
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Instructions
          if (!isDragging)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'اسحب ← للحذف  |  اسحب ↑ للإرسال',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
