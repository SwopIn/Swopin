import 'package:swopin/data/remote/remote_config.dart';

import '../data/news/news_notification.dart';

class NewsModule {
  static NewsRepository? _repository;

  static NewsRepository newsRepository() {
    _repository ??=
        NewsRepositoryImpl(remoteConfigService: RemoteConfigService());
    return _repository!;
  }
}
