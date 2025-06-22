🎯 App Overview — "SocialCard Pro"
A sleek, animated Flutter app for sharing rich personal profiles via customizable QR codes or links, with:

Unlimited links users name and assign an icon.

Fully customizable QR style (colors, shapes, logo, embedded).

Editable link descriptions (display text instead of raw URL).

Custom expiration options for both QR and link.

**Contact integration**: Import phone contacts and discover who's on SocialCard.

**Privacy controls**: Choose to be discoverable by contacts.

**Selective sharing**: Choose which social links to include per QR/link.

**Preset management**: Save and reuse QR/link settings.

Deep linking: opens in-app if installed, else web fallback offering a quick preview and app download.

State management: Flutter BLoC

🔑 Core Features

1. 🛡️ Authentication & Security
   Google Sign-In + Phone OTP via Firebase Auth.

Secure Firestore access: user can only view/edit their own data.

**Privacy settings**: Users control if they're discoverable by phone contacts.

One-time or expiring QR/link:

Users set expiry (e.g., 1 hour, 3 days, scan count).

After expiration, link/QR auto-invalidates.

Backend checks expiry before displaying profile and refuses invalid ones.

2. 📱 Contact Integration & Discovery
   **Import phone contacts**: Access device contacts with permission.

**Smart matching**: Normalize and match phone numbers against app users.

**Discovery control**: Users opt-in to be discoverable via phone number.

**Contact sync**: Show which contacts are on SocialCard with their profiles.

**Invite non-users**: Easy sharing to invite contacts not on the app.

3. 🧩 Dynamic Custom Links
   Add unlimited custom slots (URL, name, icon).

Icons can be chosen from a library or auto-detected.

Edit "label" and display text.

Animated icons: scale-up on tap, ripple feedback.

**Selective sharing**: Mark which links to include in each QR/link.

4. 🎨 Custom QR & Link Generator
   Built on qr_flutter widget.

**Unified generation**: Create both QR and link simultaneously.

**Visual customization**:

- QR: foreground/background colors, eye/pattern styles, embedded logo
- Link: custom slug (e.g., socialcard.app/johnDoe)

High-res/printable with configurable padding.

Custom description shown beneath QR (editable text).

BLoC triggers rebuilds upon customization.

5. 🎭 Smart Preset System
   **Save settings**: Name and save QR/link configurations as presets.

**Preset includes**:

- Expiration rules (date/time/scan count)
- Selected social links to share
- Visual customization settings
- Custom slug/name

**Quick generation**: One-click generation using saved presets.

**Preset management**: Edit, duplicate, or delete saved presets.

6. 🔗 Shareable Link & QR
   **Unified sharing**: Both QR and link generated together.

**Custom settings per share**:

- Choose which social links to include
- Set expiration rules
- Add custom description

Share via system share sheet or copy to clipboard.

QR and link share the same settings & expiration.

7. 📡 Deep Linking & Fallback UI
   Use Firebase Dynamic Links.

If the app is installed: open to the shared profile.

If not: open in browser:

Quick preview of profile (only selected socials shown).

"Download the app" CTA.

Then option to revisit link.

8. 📂 Local-first Saved Contacts
   When scanning/linking profiles, they can be saved locally.

**Two sources**: Scanned QR/links + Imported phone contacts.

List view mimics native Contacts app.

Reload icon appears next to entries if the remote user has updated their info—on tap, it fetches fresh data.

Animated list: tap-to-expand with icon scaling ripple.

⚙️ Design & UX
Modern card-based layout with rounded corners, drop shadows.

Light/dark mode support with thoughtful contrast.

Smooth animated transitions using Rive/Lottie (e.g., QR generation, link copy, scanning).

Icon animations: on hover/click, they gently scale or pulse.

Bundled QR UI akin to authenticator apps (floating dialog style overlay).

Responsive tabs: switch between "My Profile" and "Scanned Contacts".

**Swappable tabs**: User can reorder tabs as preferred.

🧩 Architecture & State Management
flutter_bloc + equatable for UI/data separation.

BLoCs:

AuthBloc: handles login/logout.

ProfileBloc: manages profile CRUD + privacy settings.

QrLinkBloc: custom QR/link creation and expiry logic.

PresetBloc: manages saved QR/link presets.

ScanBloc: scanning/deep link handling + saving contacts.

ContactsBloc: local list, phone import, update reload actions.

UI widgets listen to state changes and animate accordingly.

🧩 Packages to Use
flutter_bloc, equatable

firebase_core, firebase_auth, cloud_firestore, firebase_dynamic_links

qr_flutter

qr_code_scanner or flutter_barcode_scanner

url_launcher

contacts_service, permission_handler

rive, lottie

flutter_local_notifications (optional reminders for expiry)

🚦 User Flow

1. **Initial Setup**

   - Login via Google or OTP
   - Privacy prompt: "Allow contacts with your number to discover you?"
   - Automatic profile creation

2. **Profile Setup**

   - Edit personal information (name, email, phone, bio)
   - Add unlimited custom links with icons
   - Upload profile picture
   - Set privacy preferences

3. **Contact Discovery**

   - Request contact permission
   - Import and match contacts
   - See who's on SocialCard
   - View their public profiles
   - Invite non-users

4. **QR/Link Creation**

   - Choose preset or create new
   - Select which social links to include
   - Set expiration rules
   - Customize QR appearance
   - Generate both QR and link together
   - Save as preset for future use

5. **Sharing**

   - Share QR code image or link via system share
   - Recipients see only selected social links
   - Respect expiration rules
   - Deep linking opens app if installed

6. **Contact Management**
   - View imported contacts on app
   - Scan others' QR codes to save
   - Receive update notifications
   - Manage local contact database

🎨 Design Principles

- **Privacy-first**: Users control discoverability
- **Flexibility**: Choose what to share per QR/link
- **Efficiency**: Save presets for quick generation
- **Simplicity**: Despite features, UI remains clean
- **Unified**: QR and link always generated together
