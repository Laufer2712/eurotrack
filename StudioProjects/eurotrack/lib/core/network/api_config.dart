class ApiConfig {
  // Cuando quieras probar en local, solo comentas la de Render y desconestas la IP
  //static const String domain = "http://204.10.163.202:8090";
  //static const String domain = "http://10.0.2.2:8090";

  // ❌ Si usas 192.168.0.105 en el emulador, NO funcionará
  static const String domain = "http://192.168.72.151:8090";

  // Prefijos globales
  static const String authEndpoint = "$domain/api/auth";
  static const String adminEndpoint = "$domain/api/admin";
  // En api_config.dart - agregar
  static const String logsEndpoint = "$adminEndpoint/logs";
}