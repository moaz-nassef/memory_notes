<div align="center">

# 🧠 Memory Notes

**Capture every thought — text, voice, images & checklists — beautifully offline.**

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue?style=for-the-badge&logo=flutter&logoColor=white&color=02569B)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white&color=02569B)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-purple?style=for-the-badge)]

</div>

---

## ✨ About the Project

**Memory Notes** is a modern note‑taking application built with **Flutter** that lets you capture ideas in every format:

- ✍️ **Text notes** with rich editing
- 🎤 **Voice notes** with built‑in recorder & playback
- 🖼️ **Image notes** from your gallery or camera
- ☑️ **Checklists / To‑do lists**
- 🧬 **Mixed notes** — combine text, audio, images & checklists in one place

Everything is stored **locally on your device** using [Hive](https://pub.dev/packages/hive) — fast, offline‑first, and fully private. No account, no cloud required. 📴

A beautiful **dark theme** with an **aurora‑style animated background**, smooth transitions, and a delightful onboarding flow makes organizing your life feel effortless.

---

## 🚀 Features

| Feature | Description |
|---|---|
| 📝 **Multiple Note Types** | Text, image, audio, checklist, and mixed notes |
| 🎙️ **Voice Recording** | Record, replay & attach multiple audio clips per note |
| 🖼️ **Image Attachments** | Pick images with full-screen preview & slideshow |
| ☑️ **Checklists** | Create and manage task lists inside any note |
| 🎨 **Color Coding** | Assign colors to your notes for quick visual scanning |
| 🔎 **Powerful Search** | Filter notes instantly by keyword & type |
| 📡 **Connectivity Aware** | Smart offline/online snackbar notifications |
| 🌌 **Aurora UI** | Animated gradient backgrounds & buttery‑smooth transitions |
| 🚀 **Onboarding** | A polished first‑run experience |
| 📦 **Fully Offline** | Local Hive storage — your notes always with you |

---

## 🧱 Tech Stack

<div align="center">

| 🛠️ Tool | Purpose |
|---|---|
| [Flutter](https://flutter.dev) | Cross‑platform UI framework |
| [Hive](https://pub.dev/packages/hive) | Ultra‑fast local NoSQL storage |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Predictable state management |
| [get_it](https://pub.dev/packages/get_it) | Service locator & DI |
| [audioplayers](https://pub.dev/packages/audioplayers) | Audio playback |
| [record](https://pub.dev/packages/record) | Voice recording |
| [image_picker](https://pub.dev/packages/image_picker) | Gallery / camera access |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Network status detection |
| [permission_handler](https://pub.dev/packages/permission_handler) | Runtime permissions |

</div>

---

## 📂 Project Structure

```
lib/
├── app_router.dart              # Named routes
├── main.dart                    # App entry point & Hive bootstrap
├── core/
│   ├── constants/               # Colors & Hive keys
│   ├── services/                # Audio recorder & playback coordinator
│   ├── theme/                   # App theme
│   └── di_container.dart        # Dependency injection
├── features/
│   ├── add_note/                # Create/edit note (cubit + view)
│   ├── connectivity/            # Online/offline detection
│   ├── notes/                   # Notes list, search, repo (BLoC)
│   └── onboarding/              # First-run onboarding
├── models/                      # NoteModel & TaskModel (Hive)
└── shared/                      # Reusable widgets, audio & effects
```

---

## ✅ Getting Started

### Prerequisites
- 🦋 **Flutter SDK** `>= 3.7.0`
- Any supported device (Android / iOS / Web / Desktop)

### Installation

```bash
# 1️⃣ Clone the repository
git clone https://github.com/moaz-nassef/memory_notes.git
cd memory_notes

# 2️⃣ Install dependencies
flutter pub get

# 3️⃣ Run the app
flutter run
```

### Build a release

```bash
flutter build apk --release    # 📱 Android
flutter build ios --release    # 🍎 iOS
```

---

## 🧭 Roadmap

- [x] Text, audio, image, checklist & mixed notes
- [x] Voice recording & multi‑audio playback
- [x] Offline‑first Hive storage
- [x] Global search
- [ ] 📤 Notes export (PDF / text)
- [ ] 🔐 Optional biometric lock
- [ ] ☁️ Optional cloud sync

---

## 🤝 Contributing

Contributions are always welcome! 🎉

1. 🍴 Fork the repository
2. 🌿 Create your feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add some amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔀 Open a Pull Request

---

## 📞 Contact

**Moaz Nassef** — [GitHub](https://github.com/moaz-nassef)

---

<div align="center">

Made with 💜 using Flutter & Dart

⭐ **Don't forget to star this repo if you like it!** ⭐

</div>