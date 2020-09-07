import 'package:contacts_service/contacts_service.dart';

import '../../entities/item.dart' as domain;

extension ItemMapper on Item {
  domain.Item toDomainEntity() => domain.Item(label, value);
}

extension ItemIterableMapper on Iterable<Item> {
  Iterable<domain.Item> toDomainEntities() => map((i) => i.toDomainEntity());
}
