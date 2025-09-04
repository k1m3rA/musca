# 🪰 Musca
![App Icon](assets/icon/iconos/android/res/mipmap-xxxhdpi/ic_launcher.png)

**Advanced mobile ballistics application for precision shooters**

Musca is a Flutter application that provides professional ballistic calculations with support for multiple weapon profiles, ammunition, and environmental conditions.

## ✨ Key Features

-  **Weapon Profiles**: Full rifle configuration with muzzle velocity, twist rate and zero distance
-  **Ammunition Management**: Cartridge database with G1/G7 ballistic coefficients
-  **Optics Configuration**: Support for different sight heights and units
-  **Environmental Conditions**: Automatically calculates the effects of temperature, pressure, humidity, and latitude using [Free Weather API](https://www.weatherapi.com/). 
-  **Ballistic Tables**: Automatic generation of firing tables
-  **Advanced Effects**: Coriolis, Magnus, windage jump and slope correction

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/your-username/musca.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```
## 🌤️ Free Weather API (Configuration)

Musca can use the [Free Weather API](https://www.weatherapi.com/) to fetch environmental conditions. Set your API key in:
- `lib/config/api_keys.dart`

Use `lib/config/api_keys_template.dart` as a template if you don't have the file yet.

## 🛠️ Technologies

- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Ballistics Physics** - Advanced simulation algorithms

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS  
- ✅ Windows
- ✅ Linux
- ✅ Web

---

## 📄 License

This project is licensed under the terms of the [GNU General Public License v3.0](LICENSE).

