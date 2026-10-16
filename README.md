# Heating Control

A simple educational Flutter application for controlling home heating systems. This project demonstrates basic Dart and Flutter concepts including variables, types, functions, classes, widgets, and state management.

## Features

- **Boiler Control**: Toggle boiler on/off for each room
- **Floor Heating Control**: Manage floor heating in kitchen and bathroom
- **Temperature Monitoring**: Track air and water temperatures
- **Auto Mode**: Automatic boiler control based on temperature thresholds
- **Real-time Statistics**: View overall home heating statistics

## Project Structure

```
lib/
├── main.dart              # App entry point and main screen
├── models/
│   └── room.dart          # Room data model
├── widgets/
│   ├── room_card.dart     # Individual room card widget
│   ├── overview_card.dart # Home overview widget
│   ├── statistics_card.dart # Statistics display widget
│   ├── device_row.dart    # Device control row widget
│   ├── stat_row.dart      # Statistics row widget
│   └── status_colors.dart # Status color utility
└── screens/              # Prepared for future screens
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Usage

- **Toggle Boiler**: Use the switch to turn boiler on/off for each room
- **Toggle Floor Heating**: Control floor heating independently
- **Auto Boiler**: Click "Auto Boiler" to automatically control boilers based on temperature (threshold: 21°C)
- **View Statistics**: Check the bottom card for overall home statistics

## Educational Purpose

This project is designed for learning Flutter and Dart. It demonstrates:
- Variables and data types
- Control flow (if statements, for loops)
- Functions and methods
- Classes and objects
- Getters and computed properties
- State management with setState
- Widget composition
- Material Design UI components

## License

This is an educational project. Feel free to use it for learning purposes.
