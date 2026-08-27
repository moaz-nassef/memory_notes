<div align="center">

# 🧠 Memory Notes
<p align="center">
  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/cover.png" alt="memory_notes cover" width="720"/>
</p>

<p align="center">
  <a href="#screenshots">
    <img src="https://img.shields.io/badge/View_All_Screenshots-02569B?style=for-the-badge&logo=image&logoColor=white" alt="View all screenshots"/>
  </a>
</p>

> **Capture everything your brain forgets — text, voice, images & checklists — then let AI turn spoken thoughts into clear, actionable notes.**

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue?style=for-the-badge&logo=flutter&logoColor=white&color=02569B)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white&color=0175C2)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State-Blocs%20%2B%20Cubits-purple?style=for-the-badge&color=7C6CFF)](https://pub.dev/packages/flutter_bloc)
[![Storage](https://img.shields.io/badge/Storage-Hive-orange?style=for-the-badge&color=FF5CA8)](https://pub.dev/packages/hive)
[![Platform](https://img.shields.io/badge/Platform-Android%20%E2%80%A2%20iOS%20%E2%80%A2%20Web%20%E2%80%A2%20Desktop-4ECDC4?style=for-the-badge)]
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge&color=4CC38A)]()

</div>

---

## 🚀 What is Memory Notes?

**Memory Notes** is a modern, **offline-first** note‑taking app that lets you think in **any format** — no account, no cloud, no waiting.

It stores everything **locally on your device** with [Hive](https://pub.dev/packages/hive), the ultra‑fast NoSQL database, so your ideas are always with you — even on a plane ✈️, in a tunnel 🚇, or in the middle of the desert 🏜️.

Every note is a **living object** that can mix together:

- ✍️ **Text** — write freely
- 🎤 **Voice memos** — record directly into the app
- 🖼️ **Images** — from gallery or camera, with slideshow
- ☑️ **Checklists** — simple to‑do lists
- 🧬 **Mixed** — combine all of the above in one single note

And all of it is wrapped in a **stunning animated dark UI** — an aurora‑style background, glass‑morphism cards, bouncy buttons, and buttery transition animations.

---

## ✨ Why it feels special

| Area | What was built |
|---|---|
| 🎙️ **Audio manager** | Every note supports **multiple voice recordings**. One global coordinator makes sure only **one audio plays at a time** (like WhatsApp/Telegram). |
| ✨ **Voice AI** | Record naturally; AI transcribes the audio, creates a title, organizes the text, and extracts actionable tasks for you to review. |
| 🔎 **Smart Arabic search** | A custom search engine that **understands Arabic** — normalizes characters, removes diacritics, ignores tatweel, and ranks results by relevance. |
| 🌌 **Aurora UI** | A custom-painted, slowly drifting animated background with purple, teal & pink light blobs. |
| 🪶 **Micro‑interactions** | Bouncy FAB, staggered card entrances, animated gradient headline, pulsing record button. |
| 📴 **Offline‑first** | Real connectivity detection (not just WiFi checks) + smart "offline" snackbars. |
| 🧺 **Orphan cleanup** | When you edit a note and remove an audio file, the physical file is **deleted from disk** too — no junk accumulating. |

---

## 🌟 Features

### ✨ Voice Notes with AI
- Record one spoken thought and get a **structured draft**: title, organized note text, and checklist tasks with durations when they are mentioned.
- The generated note opens in a dedicated **review screen**: edit the title, text, and tasks before saving anything.
- Add a **follow-up recording** while reviewing an AI note; the new transcript is merged into the existing note instead of replacing it.
- Recent local note titles and text provide bounded context, so the result understands your existing topics without storing notes in the cloud.
- If analysis fails or the connection is unavailable, the recording remains safe locally and can be retried or saved as an audio-only note.
- Analysis runs through a Supabase Edge Function using Groq speech-to-text and structured JSON extraction; the app never ships an AI provider secret.

### 🎙️ Voice Notes — done properly
- Record directly inside the note editor with a **pulsing, animated mic button**.
- **Long‑press to record**, drag:
  - ⬅️ left to **delete**
  - ⬆️ up to **send/attach**
- Live **amplitude waves** while recording.
- Attach **multiple recordings** per note — each stored as a separate file with its own duration.
- **Smart playback coordinator**: starting one recording automatically stops any other — no overlapping audio chaos.
- **Orphan-file cleanup**: files that are no longer referenced are removed from disk on save.

### 🖼️ Images
- Pick from your **gallery** or **camera**.
- Full‑screen **preview**, zoom-in experience.
- **Slideshow** mode for image notes.

### ☑️ Checklists
- Keep a to‑do list right inside your note.
- Every task tracks its own **done state**.
- Checklists are **searchable** alongside your text.

### 🔎 Smart Search — built for Arabic
Searching Arabic is tricky. Memory Notes **normalizes** the query so your typing always finds what you meant:

| Your input | Normalized to |
|---|---|
| `أحمد` `إحمد` `آحمد` | `احمد` |
| `مؤسسة` (diacritics) | `مؤسسة` → diacritics removed |
| `حبيبتي` / `حبيبتى` | `حبيبتي` ( ى → ي ) |
| `تطويل ــــ` (tatweel) | removed |

- Searches **titles, body text, AND checklist items** — everything in one shot.
- **Ranked** results: the best match floats to the top.
- Full‑screen search page with live results, dark glass theme, and friendly empty states.

### 🔐 Onboarding
A polished, three‑page first‑run experience:
> *"Your brain's external drive"* → *"Make every note yours"* → *"Works offline. Seriously."*

It appears **once**, then never again (remembered locally with Hive).

### 📡 Connectivity & Offline UX
- Connectivity is checked with a **real internet probe** (`InternetAddress.lookup`), not just "is WiFi on".
- A smart notification appears **only when the status actually flips**:
  - 🟢 *"Back online"*
  - 🔴 *"You're offline — notes keep working"*

### 🎨 Colour Coding
Every note can have a **colour identity** — pick from a beautiful palette in the editor for quick visual scanning.

---

## 🧱 Tech Stack

| Technology | Why |
|---|---|
| [Flutter](https://flutter.dev) | One codebase, all platforms |
| [Hive](https://pub.dev/packages/hive) + hive_flutter | Instant, local, key-value storage |
| [flutter_bloc](https://pub.dev/packages/flutter_bloc) | Predictable, testable state management |
| [get_it](https://pub.dev/packages/get_it) | Simple dependency injection |
| [record](https://pub.dev/packages/record) | High-quality voice recording (`.m4a`) |
| [audioplayers](https://pub.dev/packages/audioplayers) | Playback of attached voice notes |
| [path_provider](https://pub.dev/packages/path_provider) | Where audio files live on disk |
| [connectivity_plus](https://pub.dev/packages/connectivity_plus) | Network status detection |
| [permission_handler](https://pub.dev/packages/permission_handler) | Clean runtime permission handling |
| [image_picker](https://pub.dev/packages/image_picker) | Gallery & camera access |
| [flutter_image_slideshow](https://pub.dev/packages/flutter_image_slideshow) | Slideshow for image notes |
| [http](https://pub.dev/packages/http) + http_parser | Secure multipart upload to the voice-analysis service |
| [Supabase Edge Functions](https://supabase.com/docs/guides/functions) | Keeps voice-analysis credentials server-side |
| [Groq](https://groq.com) | Speech-to-text and structured AI note extraction |

---

## 🧬 Architecture

Clean, **feature-based** architecture with clear separation of concerns:

```
lib/
├── main.dart                     # Bootstrap: Hive init + DI wiring
├── app_router.dart               # Named routes + custom transitions
├── core/
│   ├── constants/                # App colours, Hive keys
│   ├── services/                 # Audio recorder, playback coordinator, file helper
│   ├── theme/                    # Dark Material theme
│   └── di_container.dart         # get_it service locator
├── features/
│   ├── notes/                    # Notes list, repo, search + cubit
│   ├── add_note/                 # Create/edit note (cubit + widgets)
│   ├── voice_analysis/           # AI recording, analysis, review + follow-ups
│   ├── connectivity/             # Real connectivity cubit + notifier
│   └── onboarding/               # First-run walkthrough
├── models/                       # NoteModel, TaskModel (Hive-annotated)
└── shared/
    ├── audio/                    # Player widget, voice overlay, badges
    ├── effects/                  # Aurora, bouncy FAB, staggered slide, gradient text
    ├── image/                    # Picker page, preview widgets
    ├── checklist/                # Checklist widget
    ├── color/                    # Colour picker sheet
    └── text/                     # Title & body fields
supabase/
└── functions/voice-analyze/      # Secure speech-to-note Edge Function
```

**Key design decisions:**

- 🧩 **State management** — Cubits listen to the Hive box as a **`Stream`**, so the UI updates **reactively** the moment anything changes.
- 🧰 **Single `NotesRepo`** is the single source of truth for all note operations (create, update, delete with audio cleanup).
- 🎛️ **`AudioPlaybackCoordinator`** — a singleton that guarantees **one playback at a time** app-wide.
- 🗂️ **Hive adapters** are registered only **once** at startup (with guard, no double registration crashes).
- 🔐 **AI secrets stay server-side** — the Flutter client uploads audio to the Edge Function; the Groq API key is read only from server environment variables.

---

## ✅ Getting Started

### Prerequisites

- 🦋 Flutter SDK `>= 3.7.0`

### Run it

```bash
# 1. Clone
git clone https://github.com/moaz-nassef/memory_notes.git
cd memory_notes

# 2. Install dependencies
flutter pub get

# 3. Launch
flutter run
```

### Build a release

```bash
flutter build apk --release   # 📱 Android
flutter build ios --release   # 🍎 iOS
```

### Enable Voice AI (optional)

Normal note-taking remains fully offline. Voice AI needs the included Supabase function deployed with a server-side `GROQ_API_KEY`:

```bash
supabase functions deploy voice-analyze
supabase secrets set GROQ_API_KEY=your_groq_key
```

Override the deployed endpoint when needed:

```bash
flutter run --dart-define=VOICE_ANALYSIS_API_BASE_URL=https://your-project.supabase.co/functions/v1
```

---

## 🧪 Tests

Quality matters — the search engine, data model, AI response parsing, and review flow are covered:

```bash
flutter test
```

- ✅ **`notes_search_test.dart`** — Arabic normalization + ranking & filtering logic
- ✅ **`note_model_test.dart`** — content detection & note-type classification
- ✅ **`voice_analysis_result_test.dart`** — validates safe parsing of structured AI responses
- ✅ **`voice_review_screen_test.dart`** — validates the editable AI review experience

---

## 🗺️ Roadmap

- [x] Text / image / audio / checklist / mixed notes
- [x] Multi‑audio voice notes with playback coordinator
- [x] Global search across titles, text & checklists
- [x] Real offline‑first storage with Hive
- [x] Animated aurora dark UI & micro-interactions
- [x] Orphan audio-file cleanup
- [x] AI voice-to-note: transcript, title, text & task extraction
- [x] AI follow-up recordings merged into the note under review
- [ ] 📤 Export notes (PDF / TXT)
- [ ] 🔐 Optional biometric lock
- [ ] ☁️ Optional cloud sync

---

## 🤝 Contributing

Contributions are always welcome! 🎉

1. 🍴 Fork the repo
2. 🌿 Create your branch (`git checkout -b feature/amazing`)
3. 💾 Commit (`git commit -m 'Add amazing thing'`)
4. 📤 Push (`git push origin feature/amazing`)
5. 🔀 Open a Pull Request

---

## 🧑‍💻 Author

**Moaz Nassef** — [GitHub](https://github.com/moaz-nassef)

---

<div align="center">

Made with 💜 using Flutter & Dart

⭐ **If you like it, please star the repo!** ⭐

</div>

<!-- SCREENSHOTS-AUTO-START -->
## Screenshots

Below are all the app screenshots. The cover image is shown above; tap the button under it to jump back here.

<p align="center"><img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%2010%20.jpeg" alt="صورة 10 " width="200"/>  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%202%20.jpeg" alt="صورة 2 " width="200"/>  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%203%20.jpeg" alt="صورة 3 " width="200"/></p>
<p align="center"><img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%204.jpeg" alt="صورة 4" width="200"/>  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%205%20.jpeg" alt="صورة 5 " width="200"/>  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%206%20.jpeg" alt="صورة 6 " width="200"/></p>
<p align="center"><img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%207%20.jpeg" alt="صورة 7 " width="200"/>  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%208%20.jpeg" alt="صورة 8 " width="200"/>  <img src="https://raw.githubusercontent.com/moaz-nassef/memory_notes/main/screenshots/%D8%B5%D9%88%D8%B1%D8%A9%209%20.jpeg" alt="صورة 9 " width="200"/></p>
<!-- SCREENSHOTS-AUTO-END -->
