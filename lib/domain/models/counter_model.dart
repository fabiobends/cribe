/// Model class representing a counter
class CounterModel {
  final int value;

  const CounterModel({required this.value});

  /// Creates a copy of this counter with the given fields replaced with the new values
  CounterModel copyWith({int? value}) {
    return CounterModel(
      value: value ?? this.value,
    );
  }

  /// Creates a counter with value incremented by 1
  CounterModel increment() {
    return copyWith(value: value + 1);
  }

  /// Creates a counter with value decremented by 1
  CounterModel decrement() {
    return copyWith(value: value - 1);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterModel && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
