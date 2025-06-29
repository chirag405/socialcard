class AuthHelper {
  static String getCurrentUrl() {
    // Mobile platforms don't have window.location
    return '';
  }

  static void replaceUrl(String url) {
    // Mobile platforms don't need URL manipulation
  }
}
