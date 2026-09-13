class Validators {
  static String? phone(String? value) {
    if (value == null || value.length != 10) return "Invalid phone";
    return null;
  }
}
