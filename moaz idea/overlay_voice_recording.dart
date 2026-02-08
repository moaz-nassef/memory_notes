
// import 'package:flutter/material.dart';

// if (showVoiceOverlay) Positioned.fill(child: _buildVoiceOverlay()),


//   Widget _buildVoiceOverlay() {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         color: Colors.black.withOpacity(0.35),
//         child: Center(
//           child: Transform.translate(
//             offset: dragOffset,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 140,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.25),
//                         blurRadius: 20,
//                         offset: Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Icon(
//                       isRecording ? Icons.mic : Icons.mic_none_rounded,
//                       color: Colors.purple,
//                       size: 56,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   isRecording
//                       ? 'جارٍ التسجيل • ${recordingSeconds}s'
//                       : 'اضغط مطولاً للتسجيل',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Column(
//                       children: [
//                         Icon(Icons.delete, color: Colors.redAccent),
//                         SizedBox(height: 6),
//                         Text(
//                           'اسحب لليمين للحذف',
//                           style: TextStyle(color: Colors.white70, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                     SizedBox(width: 40),
//                     Column(
//                       children: [
//                         Icon(Icons.send, color: Colors.greenAccent),
//                         SizedBox(height: 6),
//                         Text(
//                           'اسحب للأعلى للإرسال',
//                           style: TextStyle(color: Colors.white70, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }






//   Widget _buildImageSheet() {
//     return GestureDetector(
//       onTap: () => setState(() => showImagePicker = false),
//       child: Container(
//         color: Colors.black.withOpacity(0.3),
//         child: GestureDetector(
//           onTap: () {},
//           child: Container(
//             margin: EdgeInsets.only(top: 100),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(height: 12),
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '🖼️ اختر صورة',
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       GridView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           crossAxisSpacing: 12,
//                           mainAxisSpacing: 12,
//                         ),
//                         itemCount: sampleImages.length,
//                         itemBuilder: (context, index) {
//                           final isSelected =
//                               selectedImageUrl == sampleImages[index];

//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 selectedImageUrl = sampleImages[index];
//                                 showImagePicker = false;
//                               });
//                             },
//                             child: Hero(
//                               tag: sampleImages[index],
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(16),
//                                   border:
//                                       isSelected
//                                           ? Border.all(
//                                             color: Colors.blue,
//                                             width: 3,
//                                           )
//                                           : null,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 10,
//                                       offset: Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(14),
//                                   child: Stack(
//                                     fit: StackFit.expand,
//                                     children: [
//                                       Image.network(
//                                         sampleImages[index],
//                                         fit: BoxFit.cover,
//                                       ),
//                                       if (isSelected)
//                                         Container(
//                                           color: Colors.blue.withOpacity(0.3),
//                                           child: Center(
//                                             child: Icon(
//                                               Icons.check_circle_rounded,
//                                               color: Colors.white,
//                                               size: 32,
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
