import 'package:path_provider/path_provider.dart';

import '../common/constants.dart';

class PlatformService {

  Future<String> getAssetsDir() async {
    final basepath = (await getApplicationSupportDirectory()).path;
    return "$basepath/v${Constants.appVersion}";
  }

}
