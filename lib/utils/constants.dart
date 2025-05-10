class Constants {
  static const String apiUrl = 'http://192.168.1.110:8000/api';
  
  // Ajouter une méthode pour vérifier la connectivité
  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else {
      return 'http://192.168.1.110:8000/api';
    }
  }
}
