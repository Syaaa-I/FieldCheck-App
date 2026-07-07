import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/check_in_model.dart';


/// Screen 3 : Check-In Detail (Read-only)
class DetailScreen extends StatelessWidget {
  final CheckIn checkIn;
  const DetailScreen({super.key, required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final imageFile = File(checkIn.imagePath);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE53935)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Stack(
          children: [
            // Black Outline
            Text(
              'Check-In Detail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black,
              ),
            ),

            // Red Fill
            const Text(
              'Check-In Detail',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Photo
            imageFile.existsSync()
                ? Image.file(
                    imageFile,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 240,
                    color: const Color(0xFFEEEEEE),
                    child: const Icon(Icons.image_not_supported,
                        size: 64, color: Colors.grey),
                  ),

            // Details section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Note section
                  const Text(
                    'NOTE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDDDDDD)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFF9F9F9),
                    ),
                    child: Text(
                      checkIn.note,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 12),

                  // GPS + timestamp rows
                  _DetailRow(label: 'Latitude',
                      value: checkIn.latitude.toStringAsFixed(6)),
                  _DetailRow(label: 'Longitude',
                      value: checkIn.longitude.toStringAsFixed(6)),
                  _DetailRow(label: 'Accuracy',
                      value: '${checkIn.accuracy.toStringAsFixed(1)} m'),
                  _DetailRow(
                    label: 'Created At',
                    value: DateFormat('d MMM yyyy, HH:mm:ss')
                        .format(checkIn.createdAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Button back to home screen (history list)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        tooltip: 'Back to history',
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.home_outlined, size: 26),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widget
// ─────────────────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}