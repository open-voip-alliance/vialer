extension StringIsNumber on String {
  bool isNumeric() => num.tryParse(this) != null;
}
