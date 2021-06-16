import 'package:BabyGrowth/models/create_image_function.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';

class ShareFunction {

  shareFunction({@required GlobalKey key, @required String babyName}) async {
    final shareableImage = await CreateImageFunction.capture(key);
    Share.file(
        babyName + DateTime.now().toString(),
        babyName + DateTime.now().toString() + '.png',
        shareableImage,
        'image/png',
        text: '');
  }

}