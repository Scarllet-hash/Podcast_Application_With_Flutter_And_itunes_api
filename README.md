# Podcast_Application_With_Flutter_And_itunes_api

A Flutter application that allows you to retrieve podcasts from the iTunes API and organize them by category. This project aims to provide an intuitive user interface for listening to podcasts in various categories such as motivation, health, and much more.

## Overview

This project is based on Flutter, an open-source framework from Google, and uses the iTunes API to fetch podcast data. The application is designed to allow users to browse through different categories of podcasts and listen to episodes directly within the app.

### Features:
- Navigation through podcast categories (e.g., motivation, health, technology, etc.)
- Displaying episodes associated with each category.
- Podcast player with features such as play/pause, 10-second skip forward/backward, and a duration timer.
- Integration with the iTunes Search API to fetch podcasts categorized by genre.
- A notification system that regularly sends motivational notes and stress-relief tips.

## Getting Started

### Prerequisites
- Flutter SDK installed on your machine. You can follow the installation guide here: [Install Flutter](https://flutter.dev/docs/get-started/install).
- A text editor such as Visual Studio Code or Android Studio.
- An Android emulator or a physical device for testing the application.

### Installation
1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/Scarllet-hash/Podcast_Application_With_Flutter_And_itunes_api.git
Navigate to the project directory:

cd Podcast_Application_With_Flutter_And_itunes_api
Install the project dependencies:

flutter pub get
Run the app on a simulator or a physical device:

flutter run
You can now test the app on your device.

Usage
After launching the app, you will see a main screen displaying the available podcast categories.

Select a category to view the episodes associated with it.

You can listen to episodes directly in the app using the integrated podcast player.

You can play/pause, skip forward/backward by 10 seconds, and see the podcast's duration.

The main file main.dart contains the entry point for the application.

Other Dart files may exist to handle specific features like fetching podcasts from the API, the audio player, etc.

android/ and ios/: Contain platform-specific files for Android and iOS customizations or configurations.

test/: Contains the tests for the application, whether for UI components or logic.

How the Application Works
1. Fetching Podcasts from the iTunes API
The application queries the iTunes API to get podcasts categorized by genre (e.g., motivation, health, etc.). When a user selects a category, the podcasts associated with that category are fetched and displayed in the app.

2. Podcast Player
The app features an integrated player that allows playing podcasts. The player includes several features:

Play/Pause: Allows starting or stopping a podcast.

Skip Forward/Backward 10 Seconds: Allows navigating through an episode.

Duration Timer: Displays the total duration of the podcast and the current position.

It also includes an interface to view received notifications.





