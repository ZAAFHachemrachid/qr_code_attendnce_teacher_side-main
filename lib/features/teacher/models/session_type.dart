enum SessionType {
  td('TD'),
  tp('TP');

  final String label;
  const SessionType(this.label);

  static SessionType fromString(String value) {
    return SessionType.values.firstWhere(
      (type) => type.label.toLowerCase() == value.toLowerCase(),
      orElse: () => SessionType.td,
    );
  }

  String toJson() => label;
}
