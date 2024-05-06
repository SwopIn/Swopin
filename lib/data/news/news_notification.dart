import 'package:swopin/data/remote/remote_config.dart';

abstract class NewsRepository {
  /// Gets the link to the news.
  ///
  /// Returns a string that represents the news link.
  String getLink();

  /// Checks if there is any news available.
  ///
  /// Returns a boolean that indicates whether there is any news available.
  bool isNewsAvailable();
}

class NewsRepositoryImpl implements NewsRepository {
  final RemoteConfigService remoteConfigService;

  NewsRepositoryImpl({required this.remoteConfigService});

  @override
  String getLink() {
    return remoteConfigService.newsLink;
  }

  @override
  bool isNewsAvailable() {
    return remoteConfigService.newsLink.isNotEmpty;
  }
}
