import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../model/check_in_model.dart';
import '../service/storage.dart';
import 'package:url_launcher/url_launcher.dart';

/// Check-In Screen
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _noteCtrl   = TextEditingController();
  final _storage    = StorageService();
  final _picker     = ImagePicker();

  XFile?  _pickedImage;
  bool    _fetchingLocation = false;
  double? _lat;
  double? _lng;
  double? _accuracy;
  bool    _saving = false;

  // Camera 
  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();

    if (status.isPermanentlyDenied) {
      _snack('Camera permission permanently denied. Open Settings to allow it.');
      await openAppSettings();
      return;
    }
    if (status.isDenied) {
      _snack('Camera permission denied.');
      return;
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null && mounted) {
        setState(() => _pickedImage = image);
      }
    } catch (e) {
      _snack('Could not open camera: $e');
    }
  }

  // GPS 

  Future<void> _getLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _snack('Location services are disabled on this device.');
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      _snack('Location permission denied.');
      return;
    }
    if (perm == LocationPermission.deniedForever) {
      _snack('Location permission permanently denied. Open Settings.');
      await openAppSettings();
      return;
    }

    setState(() => _fetchingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (mounted) {
        setState(() {
          _lat              = pos.latitude;
          _lng              = pos.longitude;
          _accuracy         = pos.accuracy;
          _fetchingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _fetchingLocation = false);
        _snack('Failed to get location: $e');
      }
    }
  }

  // Location Box
  Future<void> _openInMaps() async {
    if (_lat == null || _lng == null) return;
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$_lat,$_lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _snack('Failed to open maps.');
    }
  }

  //  Save 

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null) { _snack('Please take a photo first.'); return; }
    if (_lat == null)         { _snack('Please get your location first.'); return; }

    setState(() => _saving = true);
    try {
      // Copy temp camera file → permanent app documents directory
      final dir      = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.jpg';
      final savePath = '${dir.path}/$fileName';
      await File(_pickedImage!.path).copy(savePath);

      await _storage.saveCheckIn(CheckIn(
        id:        const Uuid().v4(),
        note:      _noteCtrl.text.trim(),
        imagePath: savePath,
        latitude:  _lat!,
        longitude: _lng!,
        accuracy:  _accuracy!,
        createdAt: DateTime.now(),
      ));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check-in saved!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      }
    } catch (e) {
      _snack('Failed to save: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  //  UI 

  @override
  Widget build(BuildContext context) {
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
            Text(
              'New Check-In',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3
                ..color = Colors.black,
              ),
            ),

            const Text(
              'New Check-In',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Note
              const _Label('Note'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Note is required' : null,
              ),
              const SizedBox(height: 16),

              // Take Photo
              _RedButton(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onPressed: _takePhoto,
              ),
              const SizedBox(height: 10),

              // Image Preview
              _ImagePreview(
                imageFile: _pickedImage != null
                    ? File(_pickedImage!.path)
                    : null,
                onClear: () => setState(() => _pickedImage = null),
              ),
              const SizedBox(height: 16),

              // Get Location
              _RedButton(
                icon: Icons.location_on,
                label: 'Get Location',
                onPressed: _fetchingLocation ? null : _getLocation,
              ),
              const SizedBox(height: 10),

              // Location result
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (_lat != null && !_fetchingLocation) ? _openInMaps : null,
                child: _LocationBox(
                  fetching: _fetchingLocation,
                  lat:      _lat,
                  lng:      _lng,
                  accuracy: _accuracy,
                ),
              ),

              const SizedBox(height: 24),

              // Button save
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}

// Widget

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500,
        ),
      );
}

class _RedButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  const _RedButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? Colors.grey.shade400
              : const Color(0xFFE53935),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onClear;
  const _ImagePreview({required this.imageFile, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        border: Border.all(
          color: imageFile != null ? Colors.transparent : Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF9F9F9),
      ),
      child: imageFile != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(imageFile!, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: GestureDetector(
                    onTap: onClear,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.close, size: 16),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text('No Image',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  final bool fetching;
  final double? lat, lng, accuracy;
  const _LocationBox({
    required this.fetching,
    required this.lat,
    required this.lng,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: fetching
          ? Row(
              children: [
                const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFE53935),
                  ),
                ),
                const SizedBox(width: 12),
                Text('fetching…',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            )
          : Column(
              children: [
                _row('Latitude',  lat?.toStringAsFixed(6) ?? ''),
                const SizedBox(height: 8),
                _row('Longitude', lng?.toStringAsFixed(6) ?? ''),
                const SizedBox(height: 8),
                _row('Accuracy',
                    accuracy != null ? '${accuracy!.toStringAsFixed(1)} m' : ''),
                if (lat != null) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 14, color: Color(0xFFE53935)),
                      SizedBox(width: 4),
                      Text('Tap to view on map',
                          style: TextStyle(fontSize: 12, color: Color(0xFFE53935))),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  Widget _row(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                color: value.isEmpty ? Colors.grey.shade400 : Colors.black54,
              )),
        ],
      );
}