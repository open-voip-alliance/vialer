/// Describing a parameter that can either be [T]`|null|<unchanged>`.
///
/// Passing these to a a `copyWith` method allows for setting a value to `null`
/// while also being able to provide a value that represents `<unchanged>`, a
/// property of the class that we don't want to modify.
///
/// If you provide a callback: the result of that callback will be treated
/// as a property to set on the entity that is being updated, even if this
/// is a `null` value.
///
/// If you provide `null` rather than a callback: the argument will be ignored±
/// and not modified on the entity.
///
/// Without this it would not be possible to set values to `null` in
/// a `copyWith`.
typedef NullableCopyWithArgument<T> = T? Function()?;

extension Value<T> on NullableCopyWithArgument<T> {
  T? valueOrNull({required T? unmodified}) =>
      this != null ? this!() : unmodified;

  T valueOrFallback({required T? unmodified, required T fallback}) =>
      valueOrNull(unmodified: unmodified) ?? fallback;
}
