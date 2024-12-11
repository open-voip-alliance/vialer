import 'package:flutter_test/flutter_test.dart';
import 'package:vialer/domain/util/phone_number.dart';

void main() {
  test('it can properly determine if a number is internal or not', () {
    expect('456'.isInternalNumber, isTrue);
    expect('4445'.isInternalNumber, isTrue);
    expect('123'.isInternalNumber, isTrue);
    expect('982'.isInternalNumber, isTrue);
    expect('0611112222'.isInternalNumber, isFalse);
    expect('00611112222'.isInternalNumber, isFalse);
    expect('+31611112222'.isInternalNumber, isFalse);
    // Luxembourg number
    expect('+351112222'.isInternalNumber, isFalse);
  });
}
