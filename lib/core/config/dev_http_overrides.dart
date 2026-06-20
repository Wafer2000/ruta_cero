import 'dart:io';

/// Solo para DESARROLLO — bypassa verificación de certificados SSL
/// Necesario cuando un firewall corporativo intercepta HTTPS
/// NUNCA usar en producción
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
