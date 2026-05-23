/// Represents a photo from the Unsplash API
class UnsplashPhoto {
  final String id;
  final String? description;
  final UnsplashUrls urls;
  final UnsplashUser user;
  final String? downloadLocationUrl;

  const UnsplashPhoto({
    required this.id,
    this.description,
    required this.urls,
    required this.user,
    this.downloadLocationUrl,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    return UnsplashPhoto(
      id: json['id'] as String,
      description:
          json['description'] as String? ?? json['alt_description'] as String?,
      urls: UnsplashUrls.fromJson(json['urls'] as Map<String, dynamic>),
      user: UnsplashUser.fromJson(json['user'] as Map<String, dynamic>),
      downloadLocationUrl: json['links'] != null
          ? (json['links'] as Map<String, dynamic>)['download_location']
              as String?
          : null,
    );
  }
}

/// URLs for different image sizes from Unsplash
class UnsplashUrls {
  final String raw;
  final String full;
  final String regular;
  final String small;
  final String thumb;

  const UnsplashUrls({
    required this.raw,
    required this.full,
    required this.regular,
    required this.small,
    required this.thumb,
  });

  factory UnsplashUrls.fromJson(Map<String, dynamic> json) {
    return UnsplashUrls(
      raw: json['raw'] as String,
      full: json['full'] as String,
      regular: json['regular'] as String,
      small: json['small'] as String,
      thumb: json['thumb'] as String,
    );
  }
}

/// Unsplash photographer info (for attribution)
class UnsplashUser {
  final String name;
  final String username;

  const UnsplashUser({required this.name, required this.username});

  factory UnsplashUser.fromJson(Map<String, dynamic> json) {
    return UnsplashUser(
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );
  }
}
