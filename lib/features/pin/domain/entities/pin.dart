class Pin {
  final int? id;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  const Pin({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });
}
