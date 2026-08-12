class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final String? link;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.link,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      image: json['image'],
      link: json['link'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image,
      'link': link,
      'isActive': isActive,
    };
  }
}
