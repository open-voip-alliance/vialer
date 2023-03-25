import 'package:flutter/cupertino.dart';

import '../../../../../../domain/user/info/build_info.dart';
import 'build_info.dart';

class Footer extends StatelessWidget {
  final BuildInfo? buildInfo;

  const Footer({required this.buildInfo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          if (buildInfo != null) BuildInfoPill(buildInfo!),
        ],
      ),
    );
  }
}
