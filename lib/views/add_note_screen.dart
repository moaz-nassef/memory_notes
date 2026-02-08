import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memory_notes/models/note_model.dart';
import 'package:memory_notes/views/Image_Picker_Page.dart';
import 'package:memory_notes/views/buildVoiceOverlay.dart';
import 'package:memory_notes/views/build_Floating_Button.dart';
import 'dart:ui';

import 'package:memory_notes/views/top_Bar_AddNote.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();

  String? selectedImageUrl;
  bool hasAudio = false;
  Color selectedColor = Color(0xFF667EEA);
  bool showColorPicker = false;
  bool showImagePicker = false;

  late AnimationController _fabController;
  late AnimationController _sheetController;

  bool isRecording = false;
  bool showVoiceOverlay = false;

  Offset dragOffset = Offset.zero;

  List<File> selectedImages = [];

  late AnimationController _pulseController;
  int recordingSeconds = 0;

  bool canSaveNote({
    required String title,
    String? text,
    String? imagePath,
    String? audioPath,
  }) {
    if (title.trim().isEmpty) return false;

    final hasText = text != null && text.trim().isNotEmpty;
    final hasImage = imagePath != null;
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
    _fabController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _sheetController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    // جديد
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
    _fabController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final isValid = canSaveNote(
      title: _titleController.text,
      text: _textController.text,
      imagePath: selectedImageUrl,
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
      imagePath: selectedImageUrl,
      audioPath: hasAudio ? 'path/to/audio.mp3' : null,
      createdAt: DateTime.now(),
      color: selectedColor.value, // 🔥 مهم
    );

    final box = Hive.box<NoteModel>('notesBox');
    box.add(note);

    Navigator.pop(context);
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
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            // color: selectedColor.withOpacity(0.5),
                          ),
                          decoration: InputDecoration(
                            fillColor: Colors.white.withOpacity(0.009),
                            filled: true,
                            hintText: '✨ title...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                        SizedBox(height: 16),

                        // ✅ Selected Image with Hero
                        if (selectedImageUrl != null)
                          Hero(
                            tag: selectedImageUrl!,
                            child: Stack(
                              children: [
                                Container(
                                  height: 250,
                                  width: double.infinity,
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: selectedColor.withOpacity(0.3),
                                        blurRadius: 25,
                                        offset: Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child:
                                        selectedImageUrl!.startsWith('http')
                                            ? Image.network(
                                              selectedImageUrl!,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.file(
                                              File(selectedImageUrl!),
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap:
                                        () => setState(
                                          () => selectedImageUrl = null,
                                        ),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ✅ Text Content
                        TextField(
                          controller: _textController,
                          maxLines: null,
                          minLines: 8,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.8,
                            color: Colors.grey[800],
                          ),
                          decoration: InputDecoration(
                            hintText: 'Record your thoughts here... 📝',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                          ),
                        ),

                        // ✅ Audio Badge
                        if (hasAudio)
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withOpacity(0.05),
                                  Colors.purple.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.purple.withOpacity(0.5),
                                        Colors.purple.withOpacity(1),

                                        Colors.purple.withOpacity(0.5),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),

                                  child: Icon(
                                    Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تسجيل صوتي',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'مرفق بالملاحظة',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close_rounded),
                                  color: Colors.red,
                                  onPressed:
                                      () => setState(() => hasAudio = false),
                                ),
                              ],
                            ),
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

                // Image Picker FAB
                FloatingButton(
                  icon: Icons.image_rounded,
                  color: Colors.blue,
                  onTap: () {
                    setState(() => showImagePicker = !showImagePicker);
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
            Positioned(bottom: 0, left: 0, right: 0, child: buildColorSheet()),

          // ✅ Image Picker Bottom Sheet
          if (showImagePicker)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final images = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ImagePickerPage()),
                  );
                  if (images != null && images.isNotEmpty) {
                    setState(() {
                      // use the first selected image as the note image
                      selectedImageUrl = images.first.path;
                    });
                  }
                  setState(() => showImagePicker = false);
                },
                child: Container(
                  margin: EdgeInsets.only(top: 100),
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'اضغط لفتح اختيار الصور',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
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

  // ✅ الـ Overlay المحسّن بالكامل

  Widget buildColorSheet() {
    return GestureDetector(
      onTap: () => setState(() => showColorPicker = false),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎨 اختر اللون',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: noteColors.length,
                        itemBuilder: (context, index) {
                          final item = noteColors[index];
                          final isSelected = item['color'] == selectedColor;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedColor = item['color'];
                                showColorPicker = false;
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: item['color'],
                                    shape: BoxShape.circle,
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: Colors.black,
                                              width: 3,
                                            )
                                            : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (item['color'] as Color)
                                            .withOpacity(0.5),
                                        blurRadius: 15,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child:
                                      isSelected
                                          ? Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          )
                                          : null,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  item['name'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
