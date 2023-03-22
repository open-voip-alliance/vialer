import 'package:flutter/cupertino.dart';

import '../../../../../domain/user/user.dart';
import '../../../../resources/theme.dart';

class Header extends StatelessWidget {
  final User user;

  const Header({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 14,
      ).copyWith(
        bottom: 16,
      ),
      child: Row(
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.brand.theme.colors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.brand.theme.colors.grey6,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
