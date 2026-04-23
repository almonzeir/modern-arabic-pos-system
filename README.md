
# Modern Arabic POS System (نظام المبيعات الحديث) 🇸🇩

A premium, offline-first Point of Sale (POS) system specifically designed for local cafeterias and restaurants. Optimized for Windows Desktop with a clean, modern "Snow White" aesthetic and full Arabic RTL support.

## 🚀 Features
- **Modern "Snow White" UI:** High-contrast, clean, and professional interface built for speed and clarity.
- **Offline-First (SQLite):** Fast, local database that works without internet. Data is always safe.
- **RTL Language Support:** Fully localized in Arabic, including receipts and inputs.
- **Smart Cart Logic:** Quantity badges on menu items and real-time daily sales tracking.
- **Professional Thermal Printing:** Automatic generation of 80mm receipts with Arabic support.
- **Code Protection:** Built with obfuscation and professional packaging for production.

## 🛠 Tech Stack
- **Framework:** Flutter (Windows Desktop)
- **Database:** SQLite (via sqflite_common_ffi)
- **State Management:** Provider
- **Installer:** MSIX Packaging

## 📦 How to Install
1. Download the `نظام_المبيعات_الحديث.msix` file from the **Releases** or **Actions** tab.
2. Double-click the file and click **Install**.
3. Launch the app from your Start Menu.

## 👨‍💻 Developer Commands
### Build Production Installer
Right-click `deploy_to_production.ps1` and select **Run with PowerShell**.

### Run in Debug Mode
```powershell
flutter run -d windows
```

---
*Created with ❤️ for local businesses.*
