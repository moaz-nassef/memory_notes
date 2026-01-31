import 'package:flutter/material.dart';
import 'package:memory_notes/models/Note_Model.dart';

class customImage extends StatefulWidget {
  const customImage({super.key, required this.note});
  final NoteModel note;

  @override
  State<customImage> createState() => _customImageState();
}

class _customImageState extends State<customImage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Image.asset(
            widget.note.imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 8),
                    Text('صورة', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              );
            },
            // loadingBuilder: (context, child, loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return Center(
            //     child: CircularProgressIndicator(
            //       value:
            //           loadingProgress.expectedTotalBytes != null
            //               ? loadingProgress
            //                       .cumulativeBytesLoaded /
            //                   loadingProgress
            //                       .expectedTotalBytes!
            //               : null,
            //     ),
            //   );
            // },
          ),
        ),
      ),
    );
  }
}
