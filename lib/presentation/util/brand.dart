import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user/brand.dart';

extension BrandContext on BuildContext {
  Brand get brand => Provider.of<Brand>(this, listen: false);
}
