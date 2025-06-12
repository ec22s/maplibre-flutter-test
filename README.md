# maplibre-flutter-test

### Android, iOS, Chorme で動かすテンプレ

- original: https://github.com/stadiamaps/flutter-maplibre-gl-example

### 主な変更点

  - 最初にローカルの `style.json` を読み込み、背景地図を変更

    - `MapLibreMap` 初期化時の `styleString` にファイルパスを指定すると使ってくれる☺️

       https://github.com/maplibre/flutter-maplibre-gl/blob/main/maplibre_gl/lib/src/maplibre_map.dart#L121-L130

  - オリジナルにあった `annotation clustering` と `offline caching` を省略

  - `maplibre_gl 0.20.0` を使用

    - 0.21.0はChromeで `Unsupported operation: Platform._operatingSystem` が出る

  - `Flutter 3.24.5` を使用

    - 3.29にすると `io.flutter.plugin.common.PluginRegistry.Registrar` がなくAndroidで動かない

      参考: https://qiita.com/NikoSan/items/9a7b3dc16bb0caa3d59e

<br>

### 動作確認環境
```
$ flutter doctor -v
[!] Flutter (Channel [user-branch], 3.24.5, on macOS 14.7.1 23H222 darwin-x64, locale en-JP)
    ! Flutter version 3.24.5 on channel [user-branch] at
      /usr/local/Caskroom/flutter/3.29.2/flutter
      Currently on an unknown channel. Run `flutter channel` to switch to an
      official channel.
      If that doesn't fix the issue, reinstall Flutter by following instructions
      at https://flutter.dev/setup.
    ! Upstream repository unknown source is not a standard remote.
      Set environment variable "FLUTTER_GIT_URL" to unknown source to dismiss this
      error.
    • Framework revision dec2ee5c1f (5 months ago), 2024-11-13 11:13:06 -0800
    • Engine revision a18df97ca5
    • Dart version 3.5.4
    • DevTools version 2.37.3
    • If those were intentional, you can disregard the above warnings; however it
      is recommended to use "git" directly to perform update checks and upgrades.

[✓] Android toolchain - develop for Android devices (Android SDK version 36.0.0)
    • Android SDK at /Users/user/Library/Android/sdk
    • Platform android-36, build-tools 36.0.0
    • Java binary at: /Users/user/.jenv/versions/21.0.7/bin/java
    • Java version OpenJDK Runtime Environment Homebrew (build 21.0.7)
    • All Android licenses accepted.

[✓] Xcode - develop for iOS and macOS (Xcode 16.2)
    • Xcode at /Applications/Xcode.app/Contents/Developer
    • Build 16C5032a
    • CocoaPods version 1.16.2

[✓] Chrome - develop for the web
    • Chrome at /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

[✓] Android Studio (version 2024.3)
    • Android Studio at /Applications/Android Studio.app/Contents
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 21.0.5+-13047016-b750.29)
...
```
✅ Chrome 135.0.7049.96 (macOS 14.7.1)

✅ iPhone 7 (iOS 15.8.4)

✅ PLE-701L (Android 10, LineageOS 17.1)

<br>

以下、オリジナルのREADME

---

# flutter_maplibre_demo

An example Flutter project demonstrating how to use the [MapLibre GL wrapper](https://github.com/m0nac0/flutter-maplibre-gl)
with annotation clustering and offline caching. (Note that offline management is only available on mobile platforms.)

## Getting Started

You *will* need to set an API key in [map.dart](lib/map.dart) before running the app. You can sign up for a free
Stadia Maps API key via our [Client Dashboard](https://client.stadiamaps.com/). Otherwise, run it like
any other Flutter app.

This project is a starting point for a Flutter application, but is by no means a comprehensive guide
to all there is to know about Flutter MapLibre GL. Please refer to the project (linked above)
and the following resources for getting started with Flutter.


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Gotchas

There appear to be a few issues/inconsistencies between web and mobile. This repo is
currently tested against iOS and will have some quirks on Android and web as a result.
We have opened issues with the library to resolve these.

* https://github.com/m0nac0/flutter-maplibre-gl/issues/159
* https://github.com/m0nac0/flutter-maplibre-gl/issues/160

Finally, note that iOS Simulator currently has some issues rendering maps due to rendering
library issues, particularly on Apple Silicon. Reworking the rendering to use Metal is
actively underway upstream, which will solve the simulator issues. For now, we recommend
running on a device.
