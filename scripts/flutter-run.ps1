function flutter-refresh {
    # Clean project
    flutter clean

    # Restore dependencies
    flutter pub get

    # Run app with verbose logs
    flutter-run run --verbose
}