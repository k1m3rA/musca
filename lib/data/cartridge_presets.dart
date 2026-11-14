/// Calibres precargados con datos típicos de fábrica para autorrellenar la
/// ficha del cartucho. Son valores orientativos de cargas comerciales
/// comunes; todos los campos quedan editables tras elegir el calibre.
library;

class CartridgePreset {
  final String name;

  /// Diámetro de la bala en cm.
  final double diameterCm;

  /// Longitud de la bala en cm.
  final double bulletLengthCm;

  /// Peso en granos.
  final double bulletWeightGr;

  /// Coeficiente balístico según [bcModelType] (0 = G1, 1 = G7).
  final double ballisticCoefficient;
  final int bcModelType;

  /// Velocidad inicial típica en m/s.
  final double muzzleVelocity;

  const CartridgePreset({
    required this.name,
    required this.diameterCm,
    required this.bulletLengthCm,
    required this.bulletWeightGr,
    required this.ballisticCoefficient,
    required this.bcModelType,
    required this.muzzleVelocity,
  });
}

/// Lista ordenada alfabéticamente. .224" = 0.573 cm, .308" = 0.782 cm, etc.
const List<CartridgePreset> kCartridgePresets = [
  CartridgePreset(
    name: '.223 Remington 55 gr FMJ',
    diameterCm: 0.573,
    bulletLengthCm: 2.26,
    bulletWeightGr: 55,
    ballisticCoefficient: 0.243,
    bcModelType: 0,
    muzzleVelocity: 990,
  ),
  CartridgePreset(
    name: '.243 Winchester 100 gr',
    diameterCm: 0.617,
    bulletLengthCm: 2.71,
    bulletWeightGr: 100,
    ballisticCoefficient: 0.405,
    bcModelType: 0,
    muzzleVelocity: 905,
  ),
  CartridgePreset(
    name: '.270 Winchester 130 gr',
    diameterCm: 0.704,
    bulletLengthCm: 3.20,
    bulletWeightGr: 130,
    ballisticCoefficient: 0.460,
    bcModelType: 0,
    muzzleVelocity: 930,
  ),
  CartridgePreset(
    name: '.30-06 Springfield 180 gr',
    diameterCm: 0.782,
    bulletLengthCm: 3.30,
    bulletWeightGr: 180,
    ballisticCoefficient: 0.500,
    bcModelType: 0,
    muzzleVelocity: 820,
  ),
  CartridgePreset(
    name: '.300 Winchester Magnum 180 gr',
    diameterCm: 0.782,
    bulletLengthCm: 3.30,
    bulletWeightGr: 180,
    ballisticCoefficient: 0.523,
    bcModelType: 0,
    muzzleVelocity: 900,
  ),
  CartridgePreset(
    name: '.308 Winchester 168 gr',
    diameterCm: 0.782,
    bulletLengthCm: 3.10,
    bulletWeightGr: 168,
    ballisticCoefficient: 0.447,
    bcModelType: 0,
    muzzleVelocity: 810,
  ),
  CartridgePreset(
    name: '.338 Lapua Magnum 250 gr',
    diameterCm: 0.858,
    bulletLengthCm: 3.90,
    bulletWeightGr: 250,
    ballisticCoefficient: 0.320,
    bcModelType: 1,
    muzzleVelocity: 900,
  ),
  CartridgePreset(
    name: '6.5 Creedmoor 140 gr ELD-M',
    diameterCm: 0.671,
    bulletLengthCm: 3.55,
    bulletWeightGr: 140,
    ballisticCoefficient: 0.326,
    bcModelType: 1,
    muzzleVelocity: 830,
  ),
  CartridgePreset(
    name: '6.5 PRC 143 gr ELD-X',
    diameterCm: 0.671,
    bulletLengthCm: 3.55,
    bulletWeightGr: 143,
    ballisticCoefficient: 0.315,
    bcModelType: 1,
    muzzleVelocity: 900,
  ),
  CartridgePreset(
    name: '6.5x55 SE 140 gr',
    diameterCm: 0.671,
    bulletLengthCm: 3.40,
    bulletWeightGr: 140,
    ballisticCoefficient: 0.600,
    bcModelType: 0,
    muzzleVelocity: 800,
  ),
  CartridgePreset(
    name: '7mm Remington Magnum 162 gr ELD-X',
    diameterCm: 0.721,
    bulletLengthCm: 3.60,
    bulletWeightGr: 162,
    ballisticCoefficient: 0.315,
    bcModelType: 1,
    muzzleVelocity: 890,
  ),
  CartridgePreset(
    name: '8x68 S RWS KS 180 gr',
    diameterCm: 0.820,
    bulletLengthCm: 3.20,
    bulletWeightGr: 180,
    ballisticCoefficient: 0.380,
    bcModelType: 0,
    muzzleVelocity: 965,
  ),
  CartridgePreset(
    name: '9.3x62 286 gr',
    diameterCm: 0.930,
    bulletLengthCm: 3.10,
    bulletWeightGr: 286,
    ballisticCoefficient: 0.400,
    bcModelType: 0,
    muzzleVelocity: 720,
  ),
];
