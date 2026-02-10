import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/buildVoiceOverlay.dart';
import 'package:memory_notes/views/presentation/common/build_Floating_Button.dart';
import 'package:memory_notes/views/presentation/common/color/color_picker_sheet.dart';
import 'package:memory_notes/views/presentation/common/audio/note_audio_badge.dart';
import 'package:memory_notes/views/presentation/common/image/Image_Picker_Page.dart';
import 'package:memory_notes/views/presentation/common/image/note_image_preview.dart';
import 'package:memory_notes/views/presentation/common/text/note_text_field.dart';
import 'package:memory_notes/views/presentation/common/text/note_title_field.dart';
import 'package:memory_notes/views/presentation/common/top_Bar_AddNote.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  List<String> selectedImagePaths = [];
  bool hasAudio = false;
  Color selectedColor = Color(0xFF667EEA);
  bool showColorPicker = false;

  bool isRecording = false;
  bool showVoiceOverlay = false;

  Offset dragOffset = Offset.zero;

  late AnimationController _pulseController;
  int recordingSeconds = 0;

  bool canSaveNote({
    required String title,
    String? text,
    List<String>? imagePaths,
    String? audioPath,
  }) {
    if (title.trim().isEmpty) return false;

    final hasText = text != null && text.trim().isNotEmpty;
    final hasImage = imagePaths != null && imagePaths.isNotEmpty;
    final hasAudio = audioPath != null;

    return hasText || hasImage || hasAudio;
  }

  final List<Map<String, dynamic>> noteColors = [
    {'color': Color(0xFF667EEA), 'name': 'بنفسجي'},
    {'color': Color(0xFFFF6B6B), 'name': 'أحمر'},
    {'color': Color(0xFF4ECDC4), 'name': 'تيركواز'},
    {'color': Color(0xFFFECA57), 'name': 'أصفر'},
    {'color': Color(0xFF95E1D3), 'name': 'نعناع'},
    {'color': Color(0xFFEE5A6F), 'name': 'وردي'},
    {'color': Color(0xFF2ECC71), 'name': 'أخضر'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose(); // ✅ جديد
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final isValid = canSaveNote(
      title: _titleController.text,
      text: _textController.text,
      imagePaths: selectedImagePaths.isEmpty ? null : selectedImagePaths,
      audioPath: hasAudio ? 'path/to/audio.mp3' : null,
    );

    if (!isValid) {
      _showSnackBar('لازم تكتب عنوان وتضيف نص أو صورة أو صوت', Colors.orange);
      return;
    }

    final note = NoteModel(
      title: _titleController.text.trim(),
      text:
          _textController.text.trim().isEmpty
              ? null
              : _textController.text.trim(),
      imagePaths:
          selectedImagePaths.isEmpty ? null : List.from(selectedImagePaths),
      audioPath: hasAudio ? 'path/to/audio.mp3' : null,
      createdAt: DateTime.now(),
      color: selectedColor.value,
    );

    Navigator.pop(context, note);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // const Color.fromARGB(255, 5, 5, 5),
                  selectedColor.withOpacity(0.15),
                  const Color.fromARGB(255, 5, 5, 5),
                  selectedColor.withOpacity(0.05),
                  // const Color.fromARGB(255, 5, 5, 5),
                ],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                TopBarAddnote(
                  saveNote: _saveNote,
                  selectedColor: selectedColor,
                ),

                // Content Area
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),

                        // ✅ Title
                        NoteTitleField(controller: _titleController),

                        SizedBox(height: 16),

                        // ✅ Selected Images (slideshow)
                        if (selectedImagePaths.isNotEmpty)
                          NoteImagesSlideshow(
                            images: selectedImagePaths,
                            shadowColor: selectedColor,
                            onRemove: (index) {
                              if (!mounted) return;
                              if (index >= 0 &&
                                  index < selectedImagePaths.length) {
                                setState(() {
                                  selectedImagePaths = List.from(
                                    selectedImagePaths,
                                  )..removeAt(index);
                                });
                              }
                            },
                          ),

                        // ✅ Text Content
                        NoteTextField(controller: _textController),

                        // ✅ Audio Badge
                        if (hasAudio)
                          NoteAudioBadge(
                            onRemove: () => setState(() => hasAudio = false),
                          ),

                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Floating Action Buttons - Creative!
          Positioned(
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Color Picker FAB
                FloatingButton(
                  icon: Icons.palette_rounded,
                  color: selectedColor,
                  onTap: () {
                    setState(() => showColorPicker = !showColorPicker);
                  },
                ),

                SizedBox(height: 12),

                // Image Picker FAB — يفتح صفحة الصور ويرجع كل الصور المختارة
                FloatingButton(
                  icon: Icons.image_rounded,
                  color: Colors.blue,
                  onTap: () async {
                    final images = await Navigator.push<List<File>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ImagePickerPage(),
                      ),
                    );
                    if (images != null && images.isNotEmpty) {
                      setState(() {
                        selectedImagePaths = images.map((f) => f.path).toList();
                      });
                    }
                  },
                ),

                SizedBox(height: 12),

                // Audio FAB
                // FloatingButton(
                //   icon: hasAudio ? Icons.mic : Icons.mic_none_rounded,
                //   color: Colors.purple,
                //   onTap: () {
                //     setState(() => hasAudio = !hasAudio);
                //     _showSnackBar(
                //       hasAudio ? 'تم إضافة صوت 🎤' : 'تم إزالة الصوت',
                //       Colors.purple,
                //     );

                //   },
                // ),
                // 🎤 Audio FAB

                // ✅ تعديل الـ GestureDetector للمايك
                GestureDetector(
                  onTap: () {
                    setState(() => hasAudio = !hasAudio);
                    _showSnackBar(
                      hasAudio ? 'تم إضافة صوت 🎤' : 'تم إزالة الصوت',
                      Colors.purple,
                    );
                  },
                  onLongPressStart: (_) {
                    setState(() {
                      isRecording = true;
                      showVoiceOverlay = true;
                      recordingSeconds = 0;
                    });
                  },
                  onLongPressMoveUpdate: (details) {
                    setState(() {
                      dragOffset = details.offsetFromOrigin;
                    });
                  },
                  onLongPressEnd: (_) {
                    final isDelete = dragOffset.dx < -80;
                    final isSend = dragOffset.dy < -80;

                    if (isDelete) {
                      _showSnackBar('تم حذف التسجيل 🗑️', Colors.red);
                      setState(() => hasAudio = false);
                    } else if (isSend) {
                      _showSnackBar('تم إرسال التسجيل ✅', Colors.green);
                      setState(() => hasAudio = true);
                    }

                    setState(() {
                      isRecording = false;
                      showVoiceOverlay = false;
                      dragOffset = Offset.zero;
                    });
                  },

                  child: AnimatedScale(
                    scale: isRecording ? 1.3 : 1.0,
                    duration: Duration(milliseconds: 200),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.purple, Colors.deepPurple],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(
                                  isRecording ? 0.6 : 0.5,
                                ),
                                blurRadius:
                                    isRecording
                                        ? 25 + (15 * _pulseController.value)
                                        : 20,
                                offset: Offset(0, 10),
                                spreadRadius:
                                    isRecording
                                        ? 3 + (5 * _pulseController.value)
                                        : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            hasAudio ? Icons.mic : Icons.mic_none_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ✅ Color Picker Bottom Sheet
          if (showColorPicker)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ColorPickerSheet(
                noteColors: noteColors,
                selectedColor: selectedColor,
                onColorSelected: (color) {
                  setState(() {
                    selectedColor = color;
                    showColorPicker = false;
                  });
                },
                onClose: () => setState(() => showColorPicker = false),
              ),
            ),

          if (showVoiceOverlay)
            Positioned.fill(
              child: buildVoiceOverlay(
                dragOffset: dragOffset,
                pulseController: _pulseController,
                recordingSeconds: recordingSeconds,
              ),
            ),
        ],
      ),
    );
  }
}
