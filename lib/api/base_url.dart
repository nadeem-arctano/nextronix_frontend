class BaseUrl {
  static bool isTest = false;
  static String local = "192.168.1.88";
  static const String prod = "localhost";

  static String get baseurl => "http://${isTest ? local : prod}:8080/api/";
}
