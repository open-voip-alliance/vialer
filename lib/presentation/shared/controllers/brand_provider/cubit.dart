import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/user/get_brand.dart';
import 'state.dart';

export 'state.dart';

class BrandProviderCubit extends Cubit<BrandProviderState> {
  BrandProviderCubit()
      : super(
          BrandProviderState(GetBrand()()),
        );
}
