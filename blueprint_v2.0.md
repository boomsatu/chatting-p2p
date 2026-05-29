# Blueprint: P2P GossipSub Chat App
**Versi:** 2.0.0  
**Tanggal:** 2026-05-30  
**Status:** Draft — Revisi Bahasa & Platform  
**Paradigma:** Fully Decentralized — No Central Server

---

> ### 📋 Catatan Revisi v2.0.0
> Blueprint ini diperbarui setelah analisis mendalam tentang **kompatibilitas mobile native** dari stack teknologi awal. Stack awal menggunakan React Native + Expo + js-libp2p, namun ditemukan **hambatan teknis kritikal** yang mempengaruhi kelayakan produksi. Blueprint v2.0 merekomendasikan migrasi ke **Flutter + Rust (flutter_rust_bridge + rust-libp2p)** sebagai stack utama. Lihat Bagian 3 untuk detail lengkap analisis dan keputusan.

---

## Daftar Isi

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Arsitektur Sistem](#2-arsitektur-sistem)
3. [Analisis Stack Teknologi & Keputusan](#3-analisis-stack-teknologi--keputusan)
4. [Stack Teknologi Baru (v2.0)](#4-stack-teknologi-baru-v20)
5. [Struktur Direktori Proyek](#5-struktur-direktori-proyek)
6. [Desain Database Lokal](#6-desain-database-lokal)
7. [Protokol & Algoritma](#7-protokol--algoritma)
8. [Fitur Aplikasi — Detail Spesifikasi](#8-fitur-aplikasi--detail-spesifikasi)
9. [Desain UI/UX — Screen Flow](#9-desain-uiux--screen-flow)
10. [Keamanan & Enkripsi](#10-keamanan--enkripsi)
11. [Roadmap & Fase Pengembangan](#11-roadmap--fase-pengembangan)
12. [Checklist Progres per Fase](#12-checklist-progres-per-fase)
13. [Risiko & Mitigasi](#13-risiko--mitigasi)
14. [Referensi & Sumber Kode](#14-referensi--sumber-kode)

---

## 1. Ringkasan Eksekutif

### Visi
Membangun aplikasi chat mobile (iOS & Android) yang sepenuhnya terdesentralisasi — tidak ada server pusat, tidak ada otoritas tunggal, tidak ada titik kegagalan tunggal. Setiap perangkat bertindak sebagai node peer-to-peer dalam jaringan mesh.

### Nilai Utama
- **Privasi absolut** — pesan hanya bisa dibaca pengirim dan penerima (E2E encrypted)
- **Sensor-resistant** — tidak ada server yang bisa menutup layanan
- **Serverless** — tidak ada biaya infrastruktur server
- **Offline-resilient** — pesan tersimpan lokal, dikirim saat kembali online
- **Anonim opsional** — identitas hanya berupa PeerID kriptografis
- **Installable native app** — dapat diinstall di iOS App Store & Google Play Store

### Perbandingan dengan App Konvensional

| Aspek | WhatsApp / Telegram | App Ini (P2P) |
|---|---|---|
| Server | Terpusat | Tidak ada |
| Metadata | Disimpan server | Hanya di device |
| Downtime | Bergantung server | Tidak ada single point |
| Privasi | Server bisa akses | Zero-knowledge |
| Identitas | Nomor telepon | PeerID + Key Pair |
| Biaya Infra | Tinggi | Nol |
| Instalasi | App Store / Play Store | App Store & Play Store ✅ |

---

## 2. Arsitektur Sistem

### 2.1 Gambaran Umum Lapisan (v2.0 — Flutter + Rust)

```
┌─────────────────────────────────────────────────────┐
│              LAYER 1: UI LAYER (Dart/Flutter)        │
│   Flutter Widgets · Screens · BLoC/Riverpod         │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│           LAYER 2: APPLICATION LOGIC (Dart)          │
│   ChatService · ContactService · GroupService        │
│   NotificationService · Riverpod State               │
└───────────────────────┬─────────────────────────────┘
                        │  flutter_rust_bridge (FFI)
┌───────────────────────▼─────────────────────────────┐
│          LAYER 3: CRYPTO & IDENTITY (Rust)           │
│   libsodium-sys / sodiumoxide E2E                    │
│   KeyManager · PeerIdentity · Ed25519 · X25519       │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│        LAYER 4: P2P PROTOCOL — GOSSIPSUB (Rust)      │
│   rust-libp2p + libp2p-gossipsub                     │
│   Mesh: D=6, Dlo=4, Dhi=12                           │
│   Topic: dm:{id} · group:{id} · presence:{id}        │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│          LAYER 5: TRANSPORT LAYER (Rust)             │
│   TCP · QUIC · WebRTC (via libp2p-webrtc)            │
│   Circuit Relay v2 (NAT fallback) · DCUtR            │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│         LAYER 6: PEER DISCOVERY (Rust)               │
│   Kademlia DHT · mDNS (LAN) · Bootstrap Peers        │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│          LAYER 7: LOCAL STORAGE                      │
│   SQLite via sqflite (Dart) · flutter_secure_storage │
│   SharedPreferences (preferences)                    │
└─────────────────────────────────────────────────────┘
```

### 2.2 Topologi Jaringan P2P Mesh

Setiap device adalah node dengan peran ganda:

```
Device A ◄──────────────► Device B
   │    ╲               ╱    │
   │     ╲             ╱     │
   │      ╲           ╱      │
   │       Device C◄──       │
   │      ╱           ╲      │
   ▼     ╱             ╲     ▼
Device D ◄──────────────► Device E
```

- Setiap node memelihara **6 koneksi mesh aktif** (D=6)
- Minimum 4 koneksi (Dlo), maksimum 12 koneksi (Dhi)
- Pesan di-gossip ke semua mesh peer secara paralel
- Node yang offline tidak memutus jaringan — mesh auto-heal

### 2.3 Alur Koneksi Antar Peer

```
Peer A                    DHT / Relay                  Peer B
  │                           │                           │
  │──── Publish PeerID ───────►│                           │
  │                           │◄──── Publish PeerID ──────│
  │                           │                           │
  │──── Find Peer B ──────────►│                           │
  │◄─── Multiaddr B ──────────│                           │
  │                           │                           │
  │──── Dial TCP/QUIC/WebRTC ─────────────────────────────►│
  │◄─── Accept / ICE ─────────────────────────────────────│
  │                           │                           │
  │──── Noise Handshake ──────────────────────────────────►│
  │◄─── Noise Handshake ──────────────────────────────────│
  │                           │                           │
  │═══════════ Encrypted P2P Channel ═════════════════════│
  │                           │                           │
  │──── GossipSub Subscribe "dm:A:B" ─────────────────────►│
  │──── Send Encrypted Message ───────────────────────────►│
```

### 2.4 Arsitektur Flutter–Rust Bridge

```
Flutter (Dart)                      Rust Core
┌────────────────────┐             ┌─────────────────────┐
│  UI / Screens      │             │  libp2p Swarm        │
│  Riverpod Providers│◄── FFI ────►│  GossipSub           │
│  ChatService       │  (flutter_  │  Kad-DHT             │
│  ContactService    │  rust_      │  Transport Layer     │
│  GroupService      │  bridge)    │  Crypto (libsodium)  │
│  sqflite (SQLite)  │             │  Key Management      │
│  secure_storage    │             │  Peer Discovery      │
└────────────────────┘             └─────────────────────┘
        │                                   │
        ▼                                   ▼
  iOS / Android UI               Native P2P (compiled)
```

---

## 3. Analisis Stack Teknologi & Keputusan

> **Bagian ini adalah tambahan baru di v2.0** — berisi analisis mendetail mengapa stack teknologi diganti dari React Native + js-libp2p ke Flutter + Rust + rust-libp2p.

### 3.1 Masalah Kritis dengan Stack Awal (React Native + js-libp2p)

Stack awal di blueprint v1.0 menggunakan React Native (Expo) + js-libp2p. Setelah riset mendalam, ditemukan **5 masalah kritikal** yang bisa menghambat atau menggagalkan pengembangan:

---

#### ❌ Masalah 1: Node.js Polyfill — Fundamental & Sulit Diselesaikan

**js-libp2p dirancang untuk Node.js atau browser**, bukan React Native. Di React Native tidak ada `Buffer`, `crypto`, `stream`, `net`, `dgram`, dan puluhan modul Node.js lain yang digunakan oleh libp2p secara internal.

- Harus install dan konfigurasi puluhan polyfill: `buffer`, `stream-browserify`, `crypto-browserify`, `process`, `events`, `util`, dll.
- Metro bundler (bundler default React Native / Expo) tidak mendukung `require()` resolusi Node.js secara native.
- Butuh modifikasi `metro.config.js` dan `babel.config.js` yang kompleks.
- Polyfill sering tidak 100% kompatibel — ada edge case yang menyebabkan crash yang sulit di-debug.
- **Referensi:** Repo resmi `ipfs-shipyard/js-libp2p-react-native` sendiri menandai banyak hal sebagai "experimental" dan membutuhkan setup shimming globals yang panjang.

**Dampak:** Fase 1 saja bisa memakan 2–3 minggu hanya untuk setup polyfill, dan masih ada risiko ada dependency libp2p yang tidak bisa di-polyfill sama sekali.

---

#### ❌ Masalah 2: `@libp2p/webrtc` Tidak Berjalan di Expo Go

**`@libp2p/webrtc` membutuhkan native code** (kode C++ WebRTC). Karena itu:

- Tidak bisa dijalankan di Expo Go — harus selalu build custom development client.
- Setiap perubahan native dependency → rebuild APK/IPA penuh (bisa 20–40 menit per cycle).
- `react-native-webrtc` (alternatif) juga punya masalah kompatibilitas dengan Expo 52 (banyak issue di GitHub).
- Ini langsung menghilangkan keuntungan utama Expo: iterasi cepat.

**Dampak:** Development cycle sangat lambat. OTA updates via Expo EAS tidak berlaku untuk perubahan di layer P2P.

---

#### ❌ Masalah 3: Performa JavaScript untuk P2P — Bottleneck Serius

js-libp2p menjalankan seluruh P2P stack di JavaScript thread. Di React Native:

- JavaScript berjalan di **single thread (Hermes engine)**.
- P2P operations (DHT lookup, gossip mesh management, enkripsi/dekripsi) adalah operasi CPU-intensive.
- Ini akan **memblokir UI thread** jika tidak dihandle dengan benar, menyebabkan aplikasi terasa lag.
- Enkripsi NaCl di JavaScript jauh lebih lambat dibanding implementasi native C/Rust.
- Background P2P (heartbeat, reconnect, DHT maintenance) pada iOS sangat dibatasi oleh iOS Background Execution Limits.

**Dampak:** User experience buruk, battery drain tinggi, kemungkinan besar ditolak Apple Review karena excessive background activity.

---

#### ❌ Masalah 4: js-libp2p v2.x Belum Stabil di React Native

- js-libp2p sendiri mengakui di dokumentasinya bahwa React Native support masih **work-in-progress**.
- Banyak issue open di GitHub tentang crash di iOS/Android untuk libp2p v2.
- Library seperti `@libp2p/tcp` dan `@libp2p/kad-dht` dioptimalkan untuk Node.js server-side, bukan embedded mobile.
- Tidak ada **production app yang menggunakan js-libp2p di React Native** yang bisa dijadikan referensi.

**Dampak:** Risiko tinggi membangun di atas fondasi yang belum proven di platform target.

---

#### ❌ Masalah 5: Bundle Size & App Store

- js-libp2p dengan semua dependency P2P bisa menambah **10–30 MB** ke bundle size.
- Apple App Store membatasi cellular download ke 200 MB (total), jadi ini bukan dealbreaker, namun tetap perlu diperhatikan.
- Tree-shaking tidak sempurna di bundler React Native untuk module sistem CommonJS.

---

### 3.2 Kandidat Pengganti yang Dievaluasi

| Stack | P2P Support | Mobile Native | Produksi-Ready | Kompleksitas | Verdict |
|---|---|---|---|---|---|
| **React Native + js-libp2p** *(semula)* | ✅ GossipSub | ⚠️ Polyfill berat | ❌ Belum | Sangat Tinggi | **Ditolak** |
| **Flutter + js-libp2p (via Webview)** | ✅ GossipSub | ❌ Overhead besar | ❌ Tidak | Sangat Tinggi | **Ditolak** |
| **Kotlin Native (Android only)** | ✅ go-libp2p via JNI | ✅ Native | ✅ Proven | Tinggi | Partial — tidak cross-platform |
| **Swift (iOS only)** | ⚠️ swift-libp2p (beta) | ✅ Native | ❌ Belum | Tinggi | Partial — tidak cross-platform |
| **Flutter + Rust (flutter_rust_bridge)** | ✅ rust-libp2p | ✅ Native FFI | ✅ Proven | Sedang | **✅ DIPILIH** |
| **Kotlin Multiplatform + Rust** | ✅ rust-libp2p | ✅ Native | ⚠️ KMP masih beta | Sangat Tinggi | Ditolak |

---

### 3.3 Mengapa Flutter + Rust (flutter_rust_bridge)?

#### ✅ rust-libp2p: P2P Stack Paling Matang untuk Native

- **rust-libp2p** adalah implementasi libp2p terbaik untuk native (bukan browser/Node.js).
- Digunakan di produksi oleh **Ethereum (Lighthouse, Lodestar), IPFS (Kubo), Polkadot, Filecoin**.
- Mendukung penuh: GossipSub v1.1, Kad-DHT, Noise Protocol, mDNS, Circuit Relay v2, DCUtR, WebRTC.
- Performa native C-equivalent: enkripsi, DHT lookup, mesh management berjalan di thread terpisah.
- **Tidak ada polyfill** — Rust compile langsung ke native binary untuk ARM/x86.

#### ✅ Flutter: Cross-Platform Mobile Terbaik 2025–2026

- Compile ke **native ARM binary** (bukan interpreted seperti React Native default).
- UI konsisten di iOS dan Android tanpa perlu komponen berbeda.
- Ekosistem mature: `sqflite` (SQLite), `flutter_secure_storage` (Keychain/Keystore), `mobile_scanner` (QR), `flutter_local_notifications`.
- Hot reload untuk UI development (lapisan Dart), tidak terpengaruh perubahan Rust.
- Distribusi mudah via standard APK/IPA — bisa diinstall dan upload ke App Store / Play Store.

#### ✅ flutter_rust_bridge: Jembatan FFI Yang Terbukti

- Package `flutter_rust_bridge` (v2.x) menyederhanakan binding Dart ↔ Rust via FFI.
- **Bukan experimental** — digunakan di produksi oleh BitVPN, berbagai Web3 mobile app.
- Code generation otomatis: tulis Rust API → generate Dart binding.
- Async support: Rust future dipetakan ke Dart Future/Stream.
- Thread safety: Rust menjalankan P2P di background thread sendiri, tidak blokir UI.

#### ✅ Perbandingan Langsung

| Faktor | React Native + js-libp2p | Flutter + Rust |
|---|---|---|
| P2P maturity di mobile | ❌ Experimental | ✅ Proven (BitVPN, dsb) |
| Polyfill requirement | ❌ 15+ polyfill | ✅ Zero polyfill |
| WebRTC native | ❌ Perlu custom build | ✅ Built-in rust-libp2p |
| Background P2P | ⚠️ Terbatas JS thread | ✅ Rust native thread |
| Enkripsi performa | ⚠️ JS (lambat) | ✅ Rust (native speed) |
| Battery efficiency | ❌ Tinggi (JS loop) | ✅ Efisien (native) |
| App Store compliance | ⚠️ Berisiko | ✅ Standar |
| Dev cycle | ⚠️ Lambat (polyfill) | ✅ Hot reload (Dart UI) |
| Debug difficulty | ❌ Sangat sulit | ✅ Standar |
| Cross-platform | ✅ iOS + Android | ✅ iOS + Android |

---

## 4. Stack Teknologi Baru (v2.0)

### 4.1 Core Dependencies

#### Rust Core (`/rust/Cargo.toml`)

```toml
[package]
name = "p2pchat_core"
version = "0.1.0"
edition = "2021"

[lib]
crate-type = ["cdylib", "staticlib"]

[dependencies]
# P2P Stack
libp2p = { version = "0.54", features = [
    "gossipsub",
    "kad",
    "mdns",
    "noise",
    "yamux",
    "tcp",
    "quic",
    "webrtc",
    "dcutr",
    "relay",
    "identify",
    "request-response",
    "macros",
] }

# Async runtime
tokio = { version = "1", features = ["full"] }

# Crypto
sodiumoxide = "0.2"      # libsodium bindings (NaCl box, secretbox)
ed25519-dalek = "2"      # Ed25519 signing
x25519-dalek = "2"       # X25519 key exchange

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Utilities
uuid = { version = "1", features = ["v4"] }
anyhow = "1"
log = "0.4"

# Flutter bridge
flutter_rust_bridge = "2"

[target.'cfg(target_os = "android")'.dependencies]
android_logger = "0.13"

[target.'cfg(target_os = "ios")'.dependencies]
oslog = "0.2"
```

#### Flutter App (`pubspec.yaml`)

```yaml
name: p2pchat
description: P2P Encrypted Chat App

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.19.0"

dependencies:
  flutter:
    sdk: flutter

  # Rust Bridge
  flutter_rust_bridge: ^2.0.0

  # Database
  sqflite: ^2.3.0
  path: ^1.9.0

  # Secure Storage (Keychain/Keystore)
  flutter_secure_storage: ^9.0.0

  # Notifications
  flutter_local_notifications: ^17.0.0

  # QR Code
  mobile_scanner: ^5.0.0          # QR scanner (camera)
  qr_flutter: ^4.1.0              # QR generator

  # Navigation
  go_router: ^13.0.0

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # UI
  cached_network_image: ^3.3.0
  image_picker: ^1.1.0
  share_plus: ^9.0.0

  # Audio (Fase 5)
  record: ^5.1.0
  just_audio: ^0.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  flutter_rust_bridge_codegen: ^2.0.0
```

### 4.2 Alasan Pemilihan Komponen

| Komponen | Pilihan (v2.0) | Alasan |
|---|---|---|
| Framework UI | Flutter (Dart) | Native compile, cross-platform, ekosistem mature |
| P2P Stack | rust-libp2p | Paling mature untuk native mobile, production-proven |
| PubSub | GossipSub v1.1 (Rust) | Efisien, anti-spam, mesh management otomatis |
| FFI Bridge | flutter_rust_bridge v2 | Code gen otomatis, async support, thread-safe |
| Enkripsi DM | sodiumoxide box (X25519+XSalsa20-Poly1305) | Rust-native, no polyfill, audit NaCl |
| Enkripsi Grup | sodiumoxide secretbox (XSalsa20-Poly1305) | Symmetric, fast, proven |
| Transport | TCP + QUIC + WebRTC (rust-libp2p) | Native support, no polyfill |
| State | Riverpod | Flutter-idiomatic, code gen, testable |
| Database | SQLite via sqflite | Offline-first, relational, well-maintained |
| Key Storage | flutter_secure_storage | Keychain (iOS) / Keystore (Android), hardware-backed |
| QR Code | mobile_scanner + qr_flutter | Native camera, no Expo dependency |

---

## 5. Struktur Direktori Proyek

```
p2pchat/
├── rust/                          # Rust Core (rust-libp2p)
│   ├── src/
│   │   ├── api/                   # Public API exposed ke Flutter
│   │   │   ├── mod.rs
│   │   │   ├── node_api.rs        # start_node, stop_node, peer_count
│   │   │   ├── chat_api.rs        # send_dm, send_group_message
│   │   │   ├── discovery_api.rs   # connect_peer, find_peer
│   │   │   └── crypto_api.rs      # generate_identity, encrypt_dm, decrypt_dm
│   │   │
│   │   ├── p2p/
│   │   │   ├── mod.rs
│   │   │   ├── node.rs            # libp2p Swarm setup
│   │   │   ├── gossipsub.rs       # GossipSub config & handlers
│   │   │   ├── discovery.rs       # Kad-DHT + mDNS + Bootstrap
│   │   │   ├── relay.rs           # Circuit Relay & DCUtR
│   │   │   └── topics.rs          # Topic naming conventions
│   │   │
│   │   ├── crypto/
│   │   │   ├── mod.rs
│   │   │   ├── identity.rs        # Key gen, PeerID, Ed25519
│   │   │   ├── dm_crypto.rs       # NaCl box (X25519 DM)
│   │   │   ├── group_crypto.rs    # NaCl secretbox (symmetric group)
│   │   │   └── keystore.rs        # In-memory key management
│   │   │
│   │   ├── models/
│   │   │   ├── mod.rs
│   │   │   ├── message.rs         # MessageEnvelope, DMPayload, GroupPayload
│   │   │   ├── contact.rs         # ContactCard
│   │   │   └── group.rs           # GroupInfo
│   │   │
│   │   └── lib.rs                 # flutter_rust_bridge entry point
│   │
│   ├── Cargo.toml
│   └── build.rs                   # FFI build script
│
├── lib/                           # Flutter/Dart App
│   ├── src/
│   │   ├── bridge/                # Generated flutter_rust_bridge code
│   │   │   ├── frb_generated.dart
│   │   │   └── frb_generated.io.dart
│   │   │
│   │   ├── features/
│   │   │   ├── chat/
│   │   │   │   ├── data/          # Repository + DAO
│   │   │   │   ├── domain/        # Models + Use Cases
│   │   │   │   └── presentation/  # Screens + Providers
│   │   │   ├── contacts/
│   │   │   ├── groups/
│   │   │   ├── onboarding/
│   │   │   └── settings/
│   │   │
│   │   ├── core/
│   │   │   ├── database/          # sqflite schema + migrations
│   │   │   ├── services/          # ChatService, NotificationService
│   │   │   ├── router/            # go_router setup
│   │   │   └── theme/             # App theme + colors
│   │   │
│   │   └── shared/
│   │       ├── widgets/           # ChatBubble, QRScanner, etc.
│   │       └── utils/             # Helpers
│   │
│   └── main.dart
│
├── android/                       # Android native project
├── ios/                           # iOS native project
├── assets/
│   ├── icons/
│   └── images/
│
├── pubspec.yaml
├── Cargo.toml                     # Workspace root
└── blueprint.md
```

---

## 6. Desain Database Lokal

### 6.1 Schema SQLite (tidak berubah — tetap optimal)

```sql
-- ==========================================
-- IDENTITAS DIRI
-- ==========================================
CREATE TABLE IF NOT EXISTS identity (
  id          INTEGER PRIMARY KEY CHECK (id = 1),
  peer_id     TEXT NOT NULL UNIQUE,
  pub_key     TEXT NOT NULL,           -- base64 X25519 public key
  sign_pub_key TEXT NOT NULL,          -- base64 Ed25519 public key
  display_name TEXT NOT NULL DEFAULT 'Anonymous',
  avatar_uri  TEXT,
  created_at  INTEGER NOT NULL         -- Unix timestamp ms
);

-- ==========================================
-- KONTAK
-- ==========================================
CREATE TABLE IF NOT EXISTS contacts (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  peer_id       TEXT NOT NULL UNIQUE,
  display_name  TEXT NOT NULL,
  pub_key       TEXT NOT NULL,         -- base64 X25519 public key
  sign_pub_key  TEXT NOT NULL,         -- base64 Ed25519 public key
  multiaddrs    TEXT NOT NULL,         -- JSON array of multiaddr strings
  avatar_uri    TEXT,
  status        TEXT DEFAULT 'offline', -- 'online' | 'offline'
  last_seen     INTEGER,
  verified      INTEGER DEFAULT 0,     -- 1 = key verified via QR
  blocked       INTEGER DEFAULT 0,     -- 1 = blocked
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);

CREATE INDEX idx_contacts_peer_id ON contacts(peer_id);

-- ==========================================
-- PERCAKAPAN (DM atau Grup)
-- ==========================================
CREATE TABLE IF NOT EXISTS conversations (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  type            TEXT NOT NULL,        -- 'dm' | 'group'
  topic           TEXT NOT NULL UNIQUE, -- GossipSub topic
  target_id       TEXT NOT NULL,        -- peer_id (DM) atau group_id (group)
  display_name    TEXT NOT NULL,
  last_message    TEXT,
  last_message_at INTEGER,
  unread_count    INTEGER DEFAULT 0,
  muted           INTEGER DEFAULT 0,
  archived        INTEGER DEFAULT 0,
  created_at      INTEGER NOT NULL
);

CREATE INDEX idx_conversations_topic ON conversations(topic);
CREATE INDEX idx_conversations_last ON conversations(last_message_at DESC);

-- ==========================================
-- PESAN
-- ==========================================
CREATE TABLE IF NOT EXISTS messages (
  id              TEXT PRIMARY KEY,     -- UUID v4
  conversation_id INTEGER NOT NULL REFERENCES conversations(id),
  sender_peer_id  TEXT NOT NULL,
  content         TEXT NOT NULL,        -- plaintext setelah decrypt
  content_type    TEXT DEFAULT 'text', -- 'text' | 'image' | 'file' | 'voice' | 'system'
  status          TEXT DEFAULT 'sent', -- 'sending' | 'sent' | 'delivered' | 'read' | 'failed'
  is_mine         INTEGER NOT NULL,     -- 1 = saya pengirim
  reply_to_id     TEXT,                 -- NULL atau message.id
  metadata        TEXT,                 -- JSON: ukuran file, durasi audio, dll
  disappears_at   INTEGER,             -- NULL atau Unix ms (disappearing messages)
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_peer_id);

-- ==========================================
-- GRUP
-- ==========================================
CREATE TABLE IF NOT EXISTS groups (
  id              TEXT PRIMARY KEY,     -- UUID v4
  name            TEXT NOT NULL,
  description     TEXT,
  topic           TEXT NOT NULL UNIQUE, -- GossipSub topic
  group_key_id    TEXT NOT NULL,        -- ID key di flutter_secure_storage
  admin_peer_id   TEXT NOT NULL,
  avatar_uri      TEXT,
  member_count    INTEGER DEFAULT 1,
  created_at      INTEGER NOT NULL,
  updated_at      INTEGER NOT NULL
);

-- ==========================================
-- ANGGOTA GRUP
-- ==========================================
CREATE TABLE IF NOT EXISTS group_members (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  group_id    TEXT NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  peer_id     TEXT NOT NULL,
  role        TEXT DEFAULT 'member',   -- 'admin' | 'member'
  joined_at   INTEGER NOT NULL,
  UNIQUE(group_id, peer_id)
);

CREATE INDEX idx_group_members_group ON group_members(group_id);

-- ==========================================
-- ANTRIAN PESAN GAGAL (Offline Queue)
-- ==========================================
CREATE TABLE IF NOT EXISTS message_queue (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  message_id      TEXT NOT NULL,
  topic           TEXT NOT NULL,
  payload         TEXT NOT NULL,        -- JSON encrypted payload
  retry_count     INTEGER DEFAULT 0,
  max_retries     INTEGER DEFAULT 10,
  next_retry_at   INTEGER NOT NULL,
  created_at      INTEGER NOT NULL
);

CREATE INDEX idx_queue_next_retry ON message_queue(next_retry_at);

-- ==========================================
-- SCHEMA MIGRATIONS
-- ==========================================
CREATE TABLE IF NOT EXISTS schema_version (
  version INTEGER PRIMARY KEY,
  applied_at INTEGER NOT NULL
);
```

---

## 7. Protokol & Algoritma

### 7.1 Konvensi Penamaan Topic GossipSub

```rust
// src/p2p/topics.rs

pub fn dm_topic(peer_a: &str, peer_b: &str) -> String {
    let mut peers = [peer_a, peer_b];
    peers.sort();
    format!("dm:{}:{}", peers[0], peers[1])
}

pub fn group_topic(group_id: &str) -> String {
    format!("group:{}", group_id)
}

pub fn presence_topic(peer_id: &str) -> String {
    format!("presence:{}", peer_id)
}

pub fn invite_topic(target_peer_id: &str) -> String {
    format!("invite:{}", target_peer_id)
}
```

### 7.2 Format Pesan (Message Envelope) — Rust

```rust
// src/models/message.rs
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct MessageEnvelope {
    pub v: u8,                          // versi protokol = 1
    pub id: String,                     // UUID v4
    pub msg_type: MessageType,          // chat | ack | presence | group_invite | key_exchange
    pub sender: String,                 // PeerID pengirim
    pub timestamp: u64,                 // Unix ms
    pub payload: EncryptedPayload,
    pub sig: String,                    // base64 Ed25519 signature
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum MessageType {
    Chat,
    Ack,
    Presence,
    GroupInvite,
    KeyExchange,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct DMPayload {
    pub nonce: String,                  // base64 24-byte nonce
    pub ciphertext: String,             // base64 NaCl box encrypted
    pub sender_pub_key: String,         // base64 X25519 pub key
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct GroupPayload {
    pub group_id: String,
    pub nonce: String,                  // base64 24-byte nonce
    pub ciphertext: String,             // base64 NaCl secretbox encrypted
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ChatMessage {
    pub content: String,
    pub content_type: ContentType,      // text | image | file | voice
    pub reply_to_id: Option<String>,
    pub metadata: Option<serde_json::Value>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub enum ContentType {
    Text,
    Image,
    File,
    Voice,
}
```

### 7.3 Algoritma Key Exchange untuk Grup

```
1. Admin buat grup → generate 32-byte symmetric key (groupKey) di Rust
2. Admin simpan groupKey di flutter_secure_storage (Keychain/Keystore)

3. Admin invite Member X:
   a. Ambil pub key X25519 Member X dari kontak
   b. Buat GroupInvite payload (Rust):
      {
        groupId, groupName, groupKey,
        members: [{ peerId, pubKey }],
        adminSig: Ed25519Sign(seluruh payload, adminSignKey)
      }
   c. Enkripsi GroupInvite dengan NaCl box menggunakan pub key Member X
   d. Publish ke topic "invite:{memberXPeerId}"

4. Member X terima invite:
   a. Decrypt dengan private key sendiri (Rust)
   b. Verifikasi admin Ed25519 signature (Rust)
   c. Simpan groupKey ke flutter_secure_storage
   d. Subscribe ke topic "group:{groupId}"
   e. Kirim ACK ke admin

5. Rotasi Key (saat member keluar):
   a. Admin generate groupKey baru (Rust)
   b. Kirim groupKey baru ke semua member aktif via invite private
   c. Pesan lama tidak bisa dibaca dengan key baru (partial forward secrecy)
```

### 7.4 GossipSub Mesh Parameters (Rust)

```rust
// src/p2p/gossipsub.rs
use libp2p::gossipsub;

pub fn build_gossipsub_config() -> gossipsub::Config {
    gossipsub::ConfigBuilder::default()
        .mesh_n(6)               // D = 6 target mesh degree
        .mesh_n_low(4)           // Dlo = 4
        .mesh_n_high(12)         // Dhi = 12
        .gossip_factor(0.25)     // 25% peers gossip IHAVE
        .heartbeat_interval(std::time::Duration::from_secs(1))
        .history_length(6)
        .history_gossip(3)
        .max_transmit_size(65536)  // 64KB max message
        .flood_publish(true)
        .build()
        .expect("Valid gossipsub config")
}
```

### 7.5 Enkripsi (Rust — sodiumoxide)

```rust
// src/crypto/dm_crypto.rs
use sodiumoxide::crypto::box_;
use sodiumoxide::crypto::sign;

pub fn encrypt_dm(
    plaintext: &[u8],
    recipient_pub_key: &box_::PublicKey,
    sender_secret_key: &box_::SecretKey,
) -> Result<DMPayload, anyhow::Error> {
    let nonce = box_::gen_nonce();
    let ciphertext = box_::seal(plaintext, &nonce, recipient_pub_key, sender_secret_key);
    
    Ok(DMPayload {
        nonce: base64::encode(nonce.as_ref()),
        ciphertext: base64::encode(&ciphertext),
        sender_pub_key: base64::encode(
            box_::PublicKey::from_secret_key(sender_secret_key).as_ref()
        ),
    })
}

pub fn decrypt_dm(
    payload: &DMPayload,
    recipient_secret_key: &box_::SecretKey,
) -> Result<Vec<u8>, anyhow::Error> {
    let nonce_bytes = base64::decode(&payload.nonce)?;
    let nonce = box_::Nonce::from_slice(&nonce_bytes)
        .ok_or_else(|| anyhow::anyhow!("Invalid nonce"))?;
    let ciphertext = base64::decode(&payload.ciphertext)?;
    let sender_pub_key_bytes = base64::decode(&payload.sender_pub_key)?;
    let sender_pub_key = box_::PublicKey::from_slice(&sender_pub_key_bytes)
        .ok_or_else(|| anyhow::anyhow!("Invalid public key"))?;
    
    box_::open(&ciphertext, &nonce, &sender_pub_key, recipient_secret_key)
        .map_err(|_| anyhow::anyhow!("Decryption failed"))
}
```

### 7.6 Strategi NAT Traversal (Prioritas)

```
1. mDNS (LAN) — paling cepat, tanpa relay
   └─► jika ketemu peer di LAN yang sama → connect langsung

2. QUIC + ICE STUN — untuk internet umum
   └─► STUN servers: stun.l.google.com, stun1.l.google.com
   └─► jika ICE berhasil → direct QUIC connection

3. WebRTC (via rust-libp2p-webrtc)
   └─► native WebRTC tanpa JS overhead
   └─► jika ICE berhasil → direct WebRTC connection

4. DCUtR (Direct Connection Upgrade through Relay)
   └─► pakai relay peer sebagai koordinator hole punching
   └─► jika berhasil → direct connection

5. Circuit Relay v2 — fallback terakhir
   └─► relay traffic via peer lain di jaringan
   └─► tidak ada server sentral, peer komunal menjadi relay
```

---

## 8. Fitur Aplikasi — Detail Spesifikasi

### 8.1 Private DM (Direct Message)

**Cara Kerja:**
- Topic: `dm:{sortedPeerIDs}` (generated di Rust)
- Enkripsi: NaCl box (X25519 + XSalsa20-Poly1305) via sodiumoxide di Rust
- Kedua peer subscribe ke topic yang sama
- Pesan hanya bisa dibaca oleh pemilik private key

**Fitur dalam DM:**
- [x] Kirim pesan teks
- [x] Reply ke pesan tertentu
- [x] Status pesan: Mengirim → Terkirim → Diterima → Dibaca
- [x] Indikator online/offline kontak
- [x] Hapus pesan (lokal saja, tidak bisa hapus di peer)
- [x] Copy teks pesan
- [x] Timestamp pesan
- [x] Notifikasi pesan baru

### 8.2 Grup Chat

**Cara Kerja:**
- Topic: `group:{groupId}` (generated di Rust)
- Enkripsi: NaCl secretbox (XSalsa20-Poly1305, symmetric key) via Rust
- Group key di-share via private DM terenkripsi saat invite

**Fitur Grup:**
- [x] Buat grup baru (generate UUID + symmetric key)
- [x] Invite member via QR code atau share link deep-link
- [x] Admin bisa remove member
- [x] Member bisa keluar dari grup
- [x] Rotasi group key saat member keluar
- [x] Lihat daftar member aktif (via presence)
- [x] Reply ke pesan tertentu
- [x] Mention @member
- [x] Notifikasi mention vs pesan biasa

### 8.3 Manajemen Kontak

**Cara Kerja:**
- Identitas = PeerID (deterministik dari Ed25519 public key)
- Tambah kontak via QR code (scan via mobile_scanner) atau deep link
- QR code berisi: `{ peerId, pubKey, signPubKey, multiaddrs, displayName }`

**Fitur Kontak:**
- [x] Generate QR code identitas diri (qr_flutter)
- [x] Scan QR code kontak baru (mobile_scanner)
- [x] Share kontak via link (custom URI scheme: `p2pchat://add?data=...`)
- [x] Edit nama tampilan kontak (tersimpan lokal)
- [x] Verifikasi key (tampilkan fingerprint, bandingkan manual)
- [x] Block kontak
- [x] Hapus kontak

### 8.4 Status Presence (Online/Offline)

**Cara Kerja:**
- Subscribe ke topic `presence:{peerId}` kontak
- Kirim heartbeat setiap 30 detik: `{ peerId, timestamp, status: 'online' }`
- Jika tidak ada heartbeat dalam 90 detik → anggap offline
- Presence message tidak dienkripsi (metadata publik minimal)

### 8.5 Fitur Lanjutan (Fase 3+)

- **Voice Note** — rekam audio via `record` package, transfer via libp2p streams (Rust)
- **Share File** — file transfer P2P via libp2p request-response protocol (Rust)
- **Pesan Hilang** — auto-delete scheduler via Flutter background isolate
- **Multi-device** — key sync via QR (transfer keypair via encrypted channel)
- **Backup & Restore** — export/import database terenkripsi

---

## 9. Desain UI/UX — Screen Flow

### 9.1 Onboarding Flow

```
Splash Screen
     │
     ├──[Pengguna Baru]──► Welcome Screen
     │                          │
     │                          ▼
     │                    Generate Keys Screen
     │                    (Rust: generate keypair di background)
     │                          │
     │                          ▼
     │                    Set Display Name
     │                    + Avatar (opsional)
     │                          │
     │                          ▼
     │                    Tutorial Singkat P2P
     │                          │
     │                          ▼
     │                    ──► Main App
     │
     └──[Ada Data Lokal]──► Load Identity (Rust)
                                │
                                ▼
                           Main App
```

### 9.2 Main Navigation (Bottom Navigation Bar — Flutter)

```
┌─────────────────────────────────────┐
│                                     │
│   [Chat List Screen]                │
│   Daftar DM + Grup, sorted by       │
│   last message timestamp            │
│                                     │
├─────────────────────────────────────┤
│ 💬 Chats | 👥 Contacts | ⚙ Settings │
└─────────────────────────────────────┘
```

### 9.3 Chat Screen

```
┌────────────────────────────────────────┐
│ ← [Nama Kontak]    [●online] [⋮ menu] │
├────────────────────────────────────────┤
│                                         │
│                    [Bubble: Halo!]  ✓✓ │
│                    14:32               │
│                                         │
│ [Bubble: Hai! gimana kabar?]           │
│ 14:33                                   │
│                                         │
│                  [Bubble: Baik-baik!]  ✓│
│                  14:35                  │
│                                         │
│ ┌──────────────────────────────────┐   │
│ │ Reply to: "Hai! gimana kabar?"   │   │
│ └──────────────────────────────────┘   │
├────────────────────────────────────────┤
│ [+] [Ketik pesan...        ] [Send ►] │
└────────────────────────────────────────┘

Status bubble:
  ✓   = terkirim ke jaringan (Rust callback)
  ✓✓  = diterima peer (via ACK)
  ✓✓🔵 = dibaca peer
  ⏳   = dalam antrian (offline queue SQLite)
  ✗   = gagal
```

### 9.4 Screen Tambah Kontak

```
┌────────────────────────────────────────┐
│ Tambah Kontak                          │
├────────────────────────────────────────┤
│                                         │
│   [QR CODE DIRI SENDIRI - qr_flutter]  │
│   ┌──────────────────┐                  │
│   │ ██████████████   │                  │
│   │ ██          ██   │                  │
│   │ ██  ██████  ██   │                  │
│   │ ██  ██████  ██   │                  │
│   │ ██████████████   │                  │
│   └──────────────────┘                  │
│   12D3KooWAbc...xyz                     │
│                                         │
│   ─────────── atau ───────────          │
│                                         │
│   [📷 Scan QR Kontak - mobile_scanner] │
│   [🔗 Share Link Profil - share_plus]  │
│                                         │
└────────────────────────────────────────┘
```

---

## 10. Keamanan & Enkripsi

### 10.1 Model Keamanan

| Lapisan | Mekanisme | Library |
|---|---|---|
| Transport | Noise Protocol (XX pattern) | rust-libp2p/noise |
| DM Content | NaCl box (X25519 + XSalsa20-Poly1305) | sodiumoxide (Rust) |
| Group Content | NaCl secretbox (XSalsa20-Poly1305) | sodiumoxide (Rust) |
| Identity signing | Ed25519 | ed25519-dalek (Rust) |
| Key storage | Keychain/Keystore (hardware-backed) | flutter_secure_storage |

### 10.2 Threat Model & Mitigasi

| Ancaman | Mitigasi |
|---|---|
| Sniffing traffic jaringan | Noise Protocol di transport layer (Rust) |
| Membaca isi pesan | E2E encryption NaCl (Rust), tidak ada server |
| Man-in-the-middle | Verifikasi fingerprint via QR code out-of-band |
| Replay attack | Nonce unik per pesan + timestamp validation (Rust) |
| Spam / flood | GossipSub message scoring + rate limiting (Rust) |
| Sybil attack | Peer scoring & trust threshold |
| Key theft dari device | Hardware-backed Keychain/Keystore via flutter_secure_storage |
| Metadata analysis | Presence minimal, tidak ada server log |
| Rust memory safety | Tidak ada buffer overflow, use-after-free (Rust guarantees) |

### 10.3 Keunggulan Keamanan Rust vs JavaScript

| Aspek | JavaScript (semula) | Rust (baru) |
|---|---|---|
| Memory safety | ❌ Garbage collected, potential leaks | ✅ Ownership system, no GC |
| Crypto performance | ⚠️ Slow (JS interpretation) | ✅ Native speed |
| Side channel attacks | ⚠️ Timing attacks possible | ✅ Constant-time ops (sodiumoxide) |
| Key in memory | ⚠️ Bisa ter-garbage collect | ✅ Explicit zeroize on drop |
| Audit trail | ⚠️ Sulit diaudit | ✅ Rust code lebih eksplisit |

---

## 11. Roadmap & Fase Pengembangan

```
FASE 0 — Migration & Setup (Minggu 1–2) [BARU]
  Setup Flutter + Rust + flutter_rust_bridge
  Proof of concept: libp2p node di Flutter

FASE 1 — Foundation (Minggu 3–6) [diperpanjang]
  Rust core: libp2p node + crypto identity + GossipSub
  Flutter: database + state management + basic UI shell

FASE 2 — Core P2P Chat (Minggu 7–10)
  DM terenkripsi + discovery kontak + basic UI

FASE 3 — Grup & UX (Minggu 11–14)
  Grup chat + invite system + polish UI + notifikasi

FASE 4 — Resilience & Polish (Minggu 15–18)
  Offline queue + NAT optimization + testing + App Store prep

FASE 5 — Advanced Features (Minggu 19–26)
  Voice note + file share + multi-device + beta release
```

---

## 12. Checklist Progres per Fase

> **Petunjuk:** Tandai dengan `[x]` saat item selesai. Tandai `[~]` saat sedang dikerjakan.

---

### ✅ FASE 0 — Migration & Setup (Minggu 1–2) [BARU]

#### 0.1 Setup Lingkungan
- [ ] Install Rust toolchain + cargo
- [ ] Install Flutter SDK 3.19+
- [ ] Install Android NDK r25+ (untuk cross-compile Rust ke Android)
- [ ] Install Xcode 15+ (untuk iOS build)
- [ ] Setup cargo-ndk untuk cross-compile Android (aarch64, armv7, x86_64)
- [ ] Setup Rust iOS targets: aarch64-apple-ios, x86_64-apple-ios-sim
- [ ] Install flutter_rust_bridge_codegen

#### 0.2 Proof of Concept
- [ ] Buat Flutter project baru dengan flutter_rust_bridge template
- [ ] Buat Rust library dengan dependency rust-libp2p minimal
- [ ] Test: call Rust function dari Dart (hello world)
- [ ] Test: start libp2p node di Rust, expose status ke Dart
- [ ] Test: run di Android emulator + iOS simulator
- [ ] Test: run di device fisik Android
- [ ] Test: run di device fisik iOS
- [ ] Benchmark: performa p2p init, memory usage, battery usage baseline

#### 0.3 Build Pipeline
- [ ] Setup build script untuk compile Rust ke Android (4 ABI)
- [ ] Setup build script untuk compile Rust ke iOS (2 arch + fat binary)
- [ ] Setup GitHub Actions CI: build Flutter + Rust untuk iOS dan Android
- [ ] Test release build APK bisa diinstall di device fisik
- [ ] Test release build IPA bisa diinstall di device fisik

---

### ✅ FASE 1 — Foundation (Minggu 3–6)

#### 1.1 Rust Core — libp2p Node
- [ ] Implementasi `create_node()` dengan config dasar di Rust
- [ ] Konfigurasi transport: TCP + QUIC
- [ ] Konfigurasi security: Noise Protocol
- [ ] Konfigurasi muxer: Yamux
- [ ] Konfigurasi services: Identify + GossipSub + Kad-DHT + DCUtR
- [ ] Konfigurasi peer discovery: Bootstrap + mDNS
- [ ] Expose API ke Flutter: `start_node()`, `stop_node()`, `peer_count()`, `node_status()`
- [ ] Test: dua node Rust bisa saling connect (integration test lokal, pure Rust)
- [ ] Test: Flutter bisa start/stop Rust node via FFI

#### 1.2 Rust Core — Crypto & Identity
- [ ] Implementasi `generate_identity()` — buat keypair (X25519 box + Ed25519 sign)
- [ ] Implementasi `encrypt_dm()` dan `decrypt_dm()` dengan NaCl box (sodiumoxide)
- [ ] Implementasi `encrypt_group()` dan `decrypt_group()` dengan NaCl secretbox
- [ ] Implementasi `sign_envelope()` dan `verify_envelope()` dengan Ed25519
- [ ] Implementasi `generate_group_key()` — random 32-byte key
- [ ] Unit test semua fungsi crypto di Rust (roundtrip encrypt-decrypt)
- [ ] Expose API ke Flutter: generate_identity, expose pubkeys, verify

#### 1.3 Flutter — Database SQLite
- [ ] Setup sqflite + migration system
- [ ] Implementasi CRUD `identity` table
- [ ] Implementasi CRUD `contacts` table
- [ ] Implementasi CRUD `conversations` table
- [ ] Implementasi CRUD `messages` table
- [ ] Implementasi CRUD `groups` + `group_members` table
- [ ] Implementasi `message_queue` untuk offline sending
- [ ] Unit test semua operasi database (Flutter)

#### 1.4 Flutter — State Management
- [ ] Setup Riverpod providers
- [ ] Provider: `nodeStatusProvider` (status node, peer count dari Rust)
- [ ] Provider: `chatProvider` (messages per conversation)
- [ ] Provider: `contactsProvider` (daftar kontak)
- [ ] Provider: `groupsProvider` (daftar grup + membership)

#### 1.5 Flutter — Key Storage
- [ ] Implementasi `KeystoreService` menggunakan `flutter_secure_storage`
- [ ] `storeIdentityKey(key)` → simpan ke Keychain/Keystore
- [ ] `loadIdentityKey()` → baca dari Keychain/Keystore
- [ ] `storeGroupKey(groupId, key)` → simpan group key
- [ ] `loadGroupKey(groupId)` → baca group key
- [ ] Test: key persist setelah app di-restart

---

### ✅ FASE 2 — Core P2P Chat (Minggu 7–10)

#### 2.1 Rust — GossipSub & Peer Discovery
- [ ] Implementasi `subscribe_topic(topic)` via Rust GossipSub
- [ ] Implementasi `publish_message(topic, payload)` via Rust GossipSub
- [ ] Setup callback/stream ke Flutter saat pesan masuk (`on_message`)
- [ ] Setup callback ke Flutter saat peer connect/disconnect
- [ ] Implementasi `connect_to_peer(multiaddr)` di Rust
- [ ] Implementasi WebRTC transport di Rust (untuk NAT traversal)
- [ ] Test: dua device bisa exchange GossipSub message via LAN

#### 2.2 Flutter — Contact Discovery via QR
- [ ] Implementasi `generate_contact_card()` — buat JSON data kontak diri
- [ ] Implementasi QR code generator menggunakan `qr_flutter`
- [ ] Implementasi QR code scanner menggunakan `mobile_scanner`
- [ ] Parse dan validasi data dari QR code
- [ ] Simpan kontak baru ke database setelah scan QR
- [ ] Test: tambah kontak via QR di 2 device fisik

#### 2.3 Flutter — Private DM
- [ ] Implementasi `ChatService.sendDM(targetPeerId, content)` — enkripsi di Rust, publish GossipSub
- [ ] Implementasi receive DM — decrypt di Rust, simpan ke SQLite
- [ ] Implementasi message deduplication
- [ ] Implementasi pesan ACK
- [ ] Test: DM terkirim dan terbaca antar 2 device fisik

#### 2.4 Flutter — Presence System
- [ ] Implementasi heartbeat timer (setiap 30 detik, publish ke Rust)
- [ ] Subscribe presence topic via Rust, callback ke Flutter
- [ ] Logika timeout 90 detik → status offline
- [ ] Update UI realtime saat status kontak berubah

#### 2.5 Flutter UI — Onboarding
- [ ] Screen: Splash / Loading
- [ ] Screen: Welcome
- [ ] Screen: Generate Keys (trigger Rust `generate_identity()`, animasi)
- [ ] Screen: Set Display Name + avatar
- [ ] Screen: Tutorial singkat P2P
- [ ] Simpan flag onboarding-completed ke SharedPreferences

#### 2.6 Flutter UI — Chat List
- [ ] Screen: Chat List (DM + grup, sorted by last message)
- [ ] Widget: ChatListItem (nama, preview, timestamp, unread badge)
- [ ] FAB: New Chat
- [ ] Pull-to-refresh
- [ ] Swipe-to-archive / swipe-to-delete

#### 2.7 Flutter UI — Chat Screen (DM)
- [ ] Screen: Chat Screen dengan header nama + status online
- [ ] Widget: ChatBubble (sent/received, timestamp, status icon)
- [ ] Widget: ChatInput (text field + send button)
- [ ] Auto-scroll ke pesan terbaru
- [ ] Keyboard avoiding behavior (iOS + Android)
- [ ] Long-press pesan → menu (Copy, Reply, Delete)
- [ ] Reply preview bar di atas input
- [ ] Status pesan: ⏳ → ✓ → ✓✓ → ✓✓🔵

---

### ✅ FASE 3 — Grup & UX (Minggu 11–14)

#### 3.1 Rust — Group Chat Backend
- [ ] Implementasi `create_group(name)` di Rust — generate UUID + group key
- [ ] Implementasi `invite_member(group_id, target_peer_id)` di Rust
- [ ] Implementasi terima invite: decrypt, verifikasi, subscribe topic
- [ ] Implementasi `leave_group(group_id)` di Rust
- [ ] Implementasi `remove_member(group_id, peer_id)` (admin) di Rust
- [ ] Implementasi rotasi group key saat member keluar
- [ ] Test alur lengkap: buat grup → invite → chat → leave

#### 3.2 Flutter UI — Grup
- [ ] Screen: Buat Grup (nama, deskripsi)
- [ ] Screen: Grup Chat (mirip DM, dengan nama grup di header)
- [ ] Screen: Info Grup (nama, anggota, admin badge)
- [ ] Screen: Invite Member (pilih dari kontak atau QR)
- [ ] Widget: MemberListItem (nama, role badge, online status)
- [ ] Dialog: Konfirmasi keluar grup
- [ ] Admin panel: remove member, edit nama grup

#### 3.3 Flutter UI — Kontak
- [ ] Screen: Daftar Kontak (sorted A-Z)
- [ ] Screen: Profil Kontak (nama, PeerID, pub key fingerprint, tombol DM)
- [ ] Screen: Tambah Kontak (QR generator + QR scanner)
- [ ] Screen: Edit Nama Kontak (lokal)
- [ ] Verifikasi key fingerprint (tampil 8 karakter pertama pubkey)
- [ ] Tombol Share Profil (share_plus)
- [ ] Implementasi Block kontak

#### 3.4 Flutter UI — Settings
- [ ] Screen: Settings (profil, network status, tentang app)
- [ ] Edit display name + avatar
- [ ] Tampilkan PeerID + QR code diri
- [ ] Network stats: connected peers, mesh size (dari Rust stream)
- [ ] Toggle: Notifikasi, Tampilkan status online
- [ ] Tombol: Export backup
- [ ] Tombol: Hapus semua data

#### 3.5 Notifikasi
- [ ] Setup `flutter_local_notifications` permission request
- [ ] Kirim local notification saat pesan DM masuk (app background)
- [ ] Kirim local notification saat pesan grup masuk dengan @mention
- [ ] Navigasi langsung ke chat screen dari notifikasi tap
- [ ] Badge count (iOS + Android)

---

### ✅ FASE 4 — Resilience & Polish (Minggu 15–18)

#### 4.1 Offline Message Queue
- [ ] Simpan ke `message_queue` SQLite saat send gagal
- [ ] Retry worker di Flutter (exponential backoff)
- [ ] Trigger retry saat Rust melaporkan peer tersambung kembali
- [ ] Status ⏳ di bubble untuk pesan dalam antrian

#### 4.2 NAT Traversal Optimization
- [ ] Implementasi prioritas transport: mDNS → QUIC → WebRTC → DCUtR → Relay
- [ ] Konfigurasi STUN servers publik (stun.l.google.com, dll)
- [ ] Implementasi auto-reconnect saat peer disconnect (Rust)
- [ ] Test koneksi lintas jaringan (mobile data vs WiFi)
- [ ] Test koneksi antar jaringan 4G (NAT ketat)

#### 4.3 Performance & UX Polish
- [ ] ListView.builder virtualization untuk message list panjang (Flutter)
- [ ] Pagination SQLite untuk konversasi lama
- [ ] Animasi transisi antar screen (Flutter Hero + page transitions)
- [ ] Skeleton loading state (shimmer)
- [ ] Error boundary untuk crash graceful (Flutter ErrorWidget)
- [ ] Haptic feedback pada send message (HapticFeedback.lightImpact)
- [ ] Dark mode support (ThemeMode.system)

#### 4.4 Testing & QA
- [ ] Rust unit test: semua fungsi crypto (>90% coverage)
- [ ] Rust integration test: node lifecycle (start, connect, disconnect, stop)
- [ ] Flutter unit test: database CRUD
- [ ] Flutter widget test: ChatBubble, ChatInput, ChatListItem
- [ ] Flutter integration test: onboarding flow
- [ ] End-to-end test: send DM (2 device / emulator)
- [ ] End-to-end test: group chat (3+ device)
- [ ] Test di device fisik iOS (minimal iPhone 12, iOS 16)
- [ ] Test di device fisik Android (minimal Android 10, API 29)
- [ ] Test koneksi lintas platform iOS ↔ Android

#### 4.5 App Store Preparation
- [ ] Setup Flutter build signing (Android keystore + iOS certificates)
- [ ] Setup fastlane atau GitHub Actions untuk build release APK + IPA
- [ ] Buat app icon 1024x1024 + semua ukuran
- [ ] Buat screenshots untuk App Store + Play Store
- [ ] Tulis deskripsi app (EN + ID)
- [ ] Review App Store Guidelines compliance (privacy, background activity)
- [ ] Review Google Play Policy compliance

#### 4.6 Security Audit
- [ ] Review semua penggunaan nonce di Rust (pastikan tidak reuse)
- [ ] Review key management (tidak ada key di logs)
- [ ] Test serangan replay (kirim envelope yang sama 2x)
- [ ] Test validasi Ed25519 signature di setiap envelope (Rust)
- [ ] Review message scoring GossipSub (cegah spam)
- [ ] Pastikan keys di-zeroize saat drop di Rust (sodiumoxide handles ini)

---

### ✅ FASE 5 — Advanced Features (Minggu 19–26)

#### 5.1 Voice Note
- [ ] Integrasi `record` package untuk rekam audio Flutter
- [ ] Kirim audio sebagai file via libp2p request-response (Rust)
- [ ] UI: waveform visualizer + playback bar (`just_audio`)
- [ ] Simpan file audio lokal setelah terima

#### 5.2 File Sharing
- [ ] Implementasi file transfer via libp2p custom protocol di Rust (`/p2pchat/file/1.0.0`)
- [ ] Progress indicator di Flutter saat upload/download
- [ ] Preview gambar di bubble
- [ ] Open file dengan app eksternal (open_file package)
- [ ] Batasi ukuran file (default 50 MB)

#### 5.3 Disappearing Messages
- [ ] UI toggle di settings percakapan: hilang setelah N menit/jam/hari
- [ ] Background task di Flutter untuk auto-delete scheduler
- [ ] Sinkronisasi setting via pesan sistem terenkripsi (Rust)

#### 5.4 Multi-Device
- [ ] QR code link device baru (scan dari device utama)
- [ ] Transfer keypair via short-lived encrypted channel (Rust)
- [ ] Sync riwayat pesan via libp2p streams (Rust)

#### 5.5 Beta Release
- [ ] Upload ke Google Play Internal Track (APK/AAB)
- [ ] Upload ke TestFlight (IPA)
- [ ] Landing page app
- [ ] Dokumentasi cara join jaringan & bootstrap nodes
- [ ] Release notes & changelog
- [ ] Feedback channel (grup di app itu sendiri)

---

## 13. Risiko & Mitigasi

| Risiko | Probabilitas | Dampak | Mitigasi |
|---|---|---|---|
| flutter_rust_bridge API berubah di minor release | Rendah | Sedang | Pin versi, baca CHANGELOG sebelum upgrade |
| Rust cross-compile error untuk iOS arm64 | Sedang | Tinggi | Setup CI dari Fase 0, solve sebelum Fase 1 |
| NAT traversal gagal di beberapa jaringan | Tinggi | Sedang | Circuit Relay v2 sebagai fallback |
| Battery drain dari Rust P2P background thread | Sedang | Sedang | Throttle heartbeat, suspend Rust swarm saat background |
| iOS background execution dibatasi | Tinggi | Sedang | Gunakan iOS Background Tasks API, edukasi user |
| Pesan loss jika kedua peer offline bersamaan | Tinggi | Sedang | Message queue SQLite + retry |
| Adopsi rendah karena tidak ada server central | Sedang | Tinggi | Bootstrap peer komunal, deep link invite mudah |
| Key hilang (reset device tanpa backup) | Sedang | Tinggi | Edukasi backup, export key QR |
| Spam dari peer tak dikenal | Sedang | Rendah | GossipSub scoring (Rust) + whitelist-only mode |
| Build size besar (Rust library) | Sedang | Rendah | Strip debug symbols, LTO (link-time optimization) |
| App Store rejection karena P2P background | Sedang | Tinggi | Review guidelines, gunakan allowed background modes |
| Rust compile time lambat (CI) | Tinggi | Rendah | Cache Rust artifacts di CI, sccache |

---

## 14. Referensi & Sumber Kode

### Repository Utama

- **rust-libp2p** — `https://github.com/libp2p/rust-libp2p`  
  Implementasi libp2p untuk Rust. Digunakan sebagai P2P core. Cek examples/gossipsub-chat.

- **flutter_rust_bridge** — `https://github.com/fzyzcjy/flutter_rust_bridge`  
  Jembatan FFI antara Flutter (Dart) dan Rust. Dokumentasi lengkap di cjycode.com/flutter_rust_bridge.

- **KickedDroid/flutter_libp2p** — `https://github.com/KickedDroid/flutter_libp2p`  
  Contoh Flutter + rust-libp2p via FFI. Titik awal proof of concept.

- **ipfs-shipyard/js-libp2p-react-native** — `https://github.com/ipfs-shipyard/js-libp2p-react-native`  
  *Referensi untuk memahami masalah* React Native + js-libp2p. Dokumentasi shimming yang dibutuhkan.

- **libp2p/universal-connectivity** — `https://github.com/libp2p/universal-connectivity`  
  Demo decentralized chat multi-implementasi (Go/Rust/TypeScript). Referensi interop.

### Dokumentasi

- rust-libp2p docs: `https://docs.rs/libp2p/latest/libp2p/`
- GossipSub spec: `https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/`
- flutter_rust_bridge docs: `https://cjycode.com/flutter_rust_bridge/`
- sodiumoxide docs: `https://docs.rs/sodiumoxide/latest/sodiumoxide/`
- Flutter sqflite: `https://pub.dev/packages/sqflite`
- flutter_secure_storage: `https://pub.dev/packages/flutter_secure_storage`
- mobile_scanner (QR): `https://pub.dev/packages/mobile_scanner`

### Paper & Spesifikasi

- GossipSub v1.1 paper: `https://arxiv.org/abs/2007.02754`
- Noise Protocol Framework: `https://noiseprotocol.org/noise.html`
- Kademlia DHT: `https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf`
- NaCl crypto: `https://nacl.cr.yp.to/`

---

*Blueprint ini adalah dokumen hidup — update seiring progres pengembangan.*  
*Tandai checklist di Bagian 12 saat setiap item selesai dikerjakan.*  
*Versi 2.0 — Direvisi 2026-05-30: Migrasi dari React Native + js-libp2p ke Flutter + Rust (rust-libp2p + flutter_rust_bridge)*
