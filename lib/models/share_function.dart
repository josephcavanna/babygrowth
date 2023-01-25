import 'create_image_function.dart';
import 'package:modern_form_esys_flutter_share/modern_form_esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';

class ShareFunction {

  shareFunction({@required GlobalKey? key, required String babyName}) async {
    final shareableImage = await CreateImageFunction.capture(key);
    Share.file(
        babyName + DateTime.now().toString(),
        '$babyName${DateTime.now()}.png',
        shareableImage,
        'image/png',
        text: '');
  }
}