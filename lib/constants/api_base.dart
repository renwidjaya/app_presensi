class ApiBase {
  static const String baseUrl = "https://api.renwidjaya.my.id";

  static const String login = "$baseUrl/api/v1-auth/login";
  static const String register = "$baseUrl/api/v1-auth/register";
  static const String userDetail = "$baseUrl/api/v1-auth/user";
  static const String presensiList = "$baseUrl/api/v1-presensi/lists";
  static const String checkin = "$baseUrl/api/v1-presensi/checkin";
  static const String checkinUpdate = "$baseUrl/api/v1-presensi/checkin";
  static const String statistik = "$baseUrl/api/v1-presensi/statistik";
  static const String profilPhoto = "$baseUrl/profil";
  static const String presensiPhoto = "$baseUrl/presensi";
}
