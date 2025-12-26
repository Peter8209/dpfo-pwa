# dpfo_vn_app (Flutter)

Vietnamese UI helper app for DPFO Typ B (DPFOBv24) with:
- Client list (SQLite)
- OCR assist (camera -> text -> parse DIČ/IČO/RČ)
- Simple tax inputs & calculator (MVP)
- XML export based on an eDane-derived DPFOBv24 template

## Run (Android / iOS simulator)
```bash
flutter pub get
flutter run
```

## iOS / Apple (build to device)
1) You need macOS + Xcode installed.
2) In project root:
```bash
flutter pub get
cd ios
pod install
cd ..
flutter run -d <your-iphone>
```

## iOS release build + TestFlight (high level)
1) Set bundle id + signing in Xcode:
   - open `ios/Runner.xcworkspace`
   - Signing & Capabilities -> select your Team
2) Bump version in `pubspec.yaml`
3) Build:
```bash
flutter build ipa
```
4) Upload to App Store Connect (TestFlight) via Xcode Organizer or Transporter.

## XML mapping notes
`lib/features/tax/xml_export.dart` fills only key fields (MVP).
If eDane complains about missing required nodes, extend mapping by:
- finding the missing tag in `assets/templates/dpfo_b_v24_template.xml`
- adding another `setByPath([...], value)` call.

The template in `assets/templates` was auto-scrubbed (empty values) from your uploaded eDane export.
