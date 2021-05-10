import 'package:contacts_service/contacts_service.dart';
import 'package:dartx/dartx.dart';

import '../../entities/item.dart' as domain;

extension ItemMapper on Item {
  domain.Item? toDomainEntity() =>
      label != null && value != null ? domain.Item(label!, value!) : null;
}

extension ItemIterableMapper on Iterable<Item> {
  Iterable<domain.Item> toDomainEntities() =>
      map((i) => i.toDomainEntity()).whereNotNull();
}
