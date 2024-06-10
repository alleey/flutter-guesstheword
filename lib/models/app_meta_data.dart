class AppMetaData {
  late String version;
  late String linkDonation;
  late String linkFeedback;

  AppMetaData({
    required this.version,
    required this.linkDonation,
    required this.linkFeedback,
  });

  AppMetaData copyWith({
    String? version,
    String? linkDonation,
    String? linkFeedback,
  }) {
    return AppMetaData(
      version: version ?? this.version,
      linkDonation: linkDonation ?? this.linkDonation,
      linkFeedback: linkFeedback ?? this.linkFeedback,
    );
  }

  factory AppMetaData.fromJson(Map<String, dynamic> json) {
    return AppMetaData(
      version: json['version'] ?? "",
      linkDonation: json['link_donate'] ?? "",
      linkFeedback: json['link_feedback'] ?? "",
    );
  }
}
