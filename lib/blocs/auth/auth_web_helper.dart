import 'dart:html' as html;

class AuthHelper {
  static String getCurrentUrl() {
    return html.window.location.href;
  }

  static void replaceUrl(String url) {
    html.window.history.replaceState(null, '', url);
  }
}
