class PrivacyPolicyData {
  static const String lastUpdated = "September 4, 2025";
  
  static const String shortPolicy = """
Musca Privacy Policy

Your privacy is important to us. This app:

• Stores all your data locally on your device
• Does not share your ballistic calculations with anyone
• Uses location only for weather data (with your permission)
• Connects to weather APIs only when you configure them
• Allows you to delete all data at any time

For full details, see our complete Privacy Policy.
""";

  static const String fullPolicyUrl = "https://github.com/k1m3rA/musca/blob/main/PRIVACY_POLICY.md";
  
  static const List<String> keyPoints = [
    "All data stored locally on your device",
    "No personal data shared with third parties",
    "Location used only for weather conditions",
    "You control all API configurations",
    "Data can be deleted anytime from settings",
  ];
  
  static const Map<String, String> permissions = {
    "Location": "To fetch current weather conditions for accurate calculations",
    "Camera": "For measurement and documentation features (optional)",
    "Sensors": "For compass and orientation data",
    "Internet": "To get weather data from configured APIs",
    "Storage": "To save your equipment profiles and calculations locally",
  };
  
  static const String contactInfo = """
Questions about privacy?
Contact us at: https://github.com/k1m3rA/musca

Your data belongs to you and stays on your device.
""";
}
