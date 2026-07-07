# **FieldCheck - Field Check-In App**

A Flutter mobile application that lets users check in at a location by taking a photo, recording GPS coordinates, and writing a note. All data is saved on the device and stays there even after closing the app.

## How to Run the App

What You Need
- Flutter SDK (version 3.10 or above)
- Android Studio or Visual Studio Code
- A real Android or iOS device (recommended for camera and GPS)

## 1. Clone the repo

```
git clone https://github.com/Syaaa-I/FieldCheck-App.git
cd FieldCheck-App
```

## 2. Install dependencies

```
flutter pub get
```

## 3. Run the app

```
flutter run
```

## Plugins Used

```
1. image_picker | version ^1.1.2 | Opens the camera to take a photo
2. geolocator | version ^13.0.2 | Gets the current GPS location
3. permission_handler | ^11.3.1 | Asks the user for camera and location permission
4. shared_preferences | ^2.3.2 | Saves check-in data on the device
5. path_provider | ^2.1.4 | Finds the right folder to store photos permanent
6. intl | ^0.19.0 | Formats dates and times
7. uuid | ^4.4.0 | Creates a unique ID for each check-in
```

## Completed Requirements

```
- [x] Home screen with list of check-ins (thumbnail + note + timestamp)
- [x] Empty state when there are no check-ins
- [x] New Check-In screen with note field (validated)
- [x] Take photo with preview
- [x] Get GPS location with loading state
- [x] Save check-in (note + photo + GPS)
- [x] Check-In Detail screen (read-only)
- [x] Data saved and stays after app is closed (only lost if uninstall, delete app data)
- [x] Camera permission handled (no crash if denied)
- [x] Location permission handled (no crash if denied)
- [x] Refresh button on Home screen
```

## Screenshots

1. Check-In History
   - !(https://github.com/Syaaa-I/FieldCheck-App/blob/main/Screenshots/Check-In%20History.jpeg)

2. New Check-In
   - !(https://github.com/Syaaa-I/FieldCheck-App/blob/main/Screenshots/Capture%20Location.jpeg)

3. Check-In Detail
   - !(https://github.com/Syaaa-I/FieldCheck-App/blob/main/Screenshots/Check-In%20Detail.jpeg)

