class ProfileModel {
  final String id;
  final String userId;

  ProfileModel({required this.id, required this.userId});
}

class PrakritiResult {
  final double vata;
  final double pitta;
  final double kapha;
  final String dominant;

  PrakritiResult({required this.vata, required this.pitta, required this.kapha, required this.dominant});
}
