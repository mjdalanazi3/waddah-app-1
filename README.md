# Waddah (وضّاح) - Educational App Frontend

- **Color Theme:** 
  - Brand Purple: `#9d4edd`
  - Deep Brand Purple: `#9000FF`
  - Success Green: `#00C853`
  - Coin/Star Yellow: `#ffb703`

## 🚀 Installation / Setup

Follow these steps to set up the project locally.

### 1. Install Flutter SDK
Ensure the **Flutter SDK** is installed and added to your system `PATH`.

Verify the installation:

```bash
flutter --version
```

---

### 2. Install Android SDK Tools
1. Open **Android Studio**  
2. Go to **SDK Manager**  
3. Select the **SDK Tools** tab  
4. Check **Android SDK Command-line Tools (latest)**  
5. Click **Apply** to install

---

### 3. Accept Android Licenses
This step is commonly forgotten.

Run the following command and accept all licenses:

```bash
flutter doctor --android-licenses
```

Type `y` for every prompt.

---

### 4. Fetch Project Dependencies
Inside the project folder, run:

```bash
flutter pub get
```

---

### 5. Verify Setup
Run:

```bash
flutter doctor
```

Ensure the **Android toolchain** shows a ✅ green checkmark.
