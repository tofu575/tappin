class Longitude {
  final double value;

  const Longitude(this.value) : assert(value >= -180.0 && value <= 180.0);
}
