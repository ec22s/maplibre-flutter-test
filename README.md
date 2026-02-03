# maplibre-flutter-test

2026年1月時点で [flutter-maplibre-gl-example](https://github.com/stadiamaps/flutter-maplibre-gl-example) をAndroid, iOS, Chormeで動かしたテスト

### オリジナルからの変更点

  - 最初にローカルの `style.json` を読み込み、背景地図を変更

    - `MapLibreMap` 初期化時の `styleString` にファイルパスを指定すると使ってくれる☺️

       https://github.com/maplibre/flutter-maplibre-gl/blob/main/maplibre_gl/lib/src/maplibre_map.dart#L121-L130

  - `Flutter 3.38` , `maplibre_gl 0.25.0` を使用

    - 合わせて Android, iOS のビルド設定を修正

  - `annotation clustering` , `offline caching` , `test/widget_test.dart` を省略

<br>

### ビルド環境
```
$ flutter doctor
[✓] Flutter (Channel stable, 3.38.9, on macOS 15.7.3 24G419 darwin-x64, locale en-JP)
[✓] Android toolchain - develop for Android devices (Android SDK version 36.0.0)
[✓] Xcode - develop for iOS and macOS (Xcode 26.2)
[✓] Chrome - develop for the web
```

### 動作確認環境

- Chrome 144.0.7559.110

- iOS Simulator (iPad 10th, iOS 17.2)

- iOS 実機 (iPhone 7, iOS 15.8.6)

- Android Virtual Device (Medium Tablet, Android 16.0)



<br>

以下、オリジナルのREADME

<br>


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
