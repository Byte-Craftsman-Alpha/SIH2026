class Formatters {
  static String maskAadhaar(String aadhaar) {
    if (aadhaar.length < 12) return aadhaar;
    return "XXXX-XXXX-${aadhaar.substring(8)}";
  }
}
