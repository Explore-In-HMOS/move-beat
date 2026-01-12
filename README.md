> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Move Beat

Move Beat is an intelligent wearable music player built with ArkTS and ArkUI, optimized for HarmonyOS smartwatches.  
It automatically changes your playlist based on your physical activity — walking, running, or stationary — and keeps playback smooth and intuitive with full crown control and background audio support.

# Preview

<p align="center">
  <img src="screenshots/output1.png" alt="Playback Screen" width="24%" />
  <img src="screenshots/output2.png" alt="Tag Songs Screen" width="24%" />
</p>

# Use Cases
- **Activity-Aware Music**: Automatically switches playlists based on detected activity (Walking / Running / Stationary) and allows manual tagging of songs.
- **Seamless Playback**: Play, pause, and skip songs directly from your watch with background playback support.
- **Smart Background Resume**: Restores playback progress and state seamlessly when reopening the app and supports lock-screen controls.

# Technology

## Stack (Languages, Frameworks, Tools, Libraries, 3rd Party)
- **Languages**: ArkTS (Ark TypeScript)
- **Frameworks/Tools**: HarmonyOS SDK 5.1.0 (API Version 18), DevEco Studio Version 5.1.0.842
- **Core Libraries & Kits**:
    - @kit.MediaKit – handles playback (play, pause, seek, skip)
    - @kit.AudioKit – controls audio streams
    - @kit.BackgroundTasksKit – ensures background music persistence
    - @kit.PerformanceAnalysisKit – logs & diagnostics
    - Crown Event APIs – hardware crown integration for rotation-based control
    - @kit.AbilityKit – UI Ability & lifecycle management

## Required Permissions
The app requires the following permissions to function:
- Background audio permission

## Diagrams - Process
```sequence
User->Move Beat: Interacts with playback controls
Move Beat->ActivityDetector: Detects physical activity
ActivityDetector->Move Beat: Sends activity type
Move Beat->MediaKit: Switches to corresponding playlist
```

# Tech Stack
- ArkTS (Ark TypeScript)
- HarmonyOS SDK 5.1.0 (API Version 18)
- MediaKit, BackgroundTasksKit, AudioKit

# Directory Structure

```text
MoveBeat/
├── audio/
│   ├── AVSessionController.ets    # Manages AV session & lock-screen control
│   ├── BackgroundUtil.ets         # Handles background running tasks
│   ├── MediaController.ets        # Core playback logic (play/pause/next/prev)
│   ├── MediaTools.ets             # Utility helpers for media and resources
├── common/
│   ├── constants/
│   │   ├── MusicData.ets          # Mock or local song data
│   ├── model/
│   │   ├── MusicModel.ets         # Defines song structure & tags
├── services/
│   ├── ActivityDetector.ets       # Detects physical activity (mock or sensor)
│   ├── ActivityMusicManager.ets   # Switches songs based on detected activity
├── pages/
│   ├── Index.ets                  # Entry screen & floating Tag button
│   ├── PlaybackPage.ets           # Central playback UI (activity chip)
│   ├── TagSongsPage.ets           # UI for tagging songs by activity
├── viewmodel/
│   ├── MainViewModel.ets          # Provides music data to the view
```

# Constraints and Restrictions

## Supported Devices
- Huawei Watch 5 and newer
- Devices running HarmonyOS 5.1.0 (API 18) or above

## Platform Constraints
- Optimized for circular displays (466×466 px).
- Touch and crown rotation are both supported.

# License (MIT)

Move Beat is distributed under the terms of the MIT License.  
See the [LICENSE](/LICENSE) file for more information.