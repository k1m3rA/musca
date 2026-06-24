import 'package:flutter/material.dart';

/// Pintor personalizado para dibujar un bocadillo (speech bubble)
/// con la punta apuntando hacia abajo.
class _BubblePainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double arrowWidth;
  final double arrowHeight;
  final double
  arrowOffset; // 0.0 = izquierda, 1.0 = derecha (relativo al ancho)
  final double borderRadius;

  _BubblePainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 1.5,
    this.arrowWidth = 20,
    this.arrowHeight = 14,
    this.arrowOffset = 0.5,
    this.borderRadius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double bodyHeight = size.height - arrowHeight;
    final double arrowX = size.width * arrowOffset;

    final path = Path();
    path.moveTo(borderRadius, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, bodyHeight - borderRadius);
    path.quadraticBezierTo(
      size.width,
      bodyHeight,
      size.width - borderRadius,
      bodyHeight,
    );
    // Flecha hacia abajo
    path.lineTo(arrowX + arrowWidth / 2, bodyHeight);
    path.lineTo(arrowX, bodyHeight + arrowHeight);
    path.lineTo(arrowX - arrowWidth / 2, bodyHeight);
    path.lineTo(borderRadius, bodyHeight);
    path.quadraticBezierTo(0, bodyHeight, 0, bodyHeight - borderRadius);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.close();

    // Sombra
    canvas.drawShadow(path, Colors.black.withOpacity(0.35), 8, false);

    // Relleno
    canvas.drawPath(path, Paint()..color = color);

    // Borde
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      old.color != color ||
      old.borderColor != borderColor ||
      old.arrowOffset != arrowOffset;
}

/// Overlay de tutorial que muestra un bocadillo apuntando al botón
/// de perfiles en la barra de navegación. Se descarta al tocarlo.
class TutorialOverlay extends StatefulWidget {
  /// Callback para cuando el usuario descarta el tutorial.
  final VoidCallback onDismiss;

  /// Callback para cuando se toca el botón resaltado.
  final VoidCallback onTargetTap;

  /// GlobalKey del botón objetivo para centrar el tutorial dinámicamente.
  final GlobalKey targetKey;

  const TutorialOverlay({
    super.key,
    required this.onDismiss,
    required this.onTargetTap,
    required this.targetKey,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _bounceAnim;

  // Posición real del botón, calculada tras el primer frame
  double? _buttonCenterX;
  double? _cutoutBottomOffset;
  bool _positionReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _bounceAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Leer la posición del botón después del primer frame completo
    // Encadenamos dos postFrameCallbacks para asegurarnos de que el layout
    // de la barra de navegación ya esté estabilizado antes de leer posiciones.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveButtonPosition();
      });
    });
  }

  void _resolveButtonPosition() {
    final targetContext = widget.targetKey.currentContext;
    if (targetContext == null || !mounted) return;

    final RenderBox box = targetContext.findRenderObject() as RenderBox;
    final Size size = box.size;

    // Si el widget todavía no tiene tamaño, reintentamos en el siguiente frame
    if (size.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resolveButtonPosition();
      });
      return;
    }

    final Offset position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    const cutoutDiameter = 65.0;

    final centerX = position.dx + size.width / 2;
    final centerY = position.dy + size.height / 2;
    final bottomOffset = (screenHeight - centerY) - cutoutDiameter / 2;

    setState(() {
      _buttonCenterX = centerX;
      _cutoutBottomOffset = bottomOffset;
      _positionReady = true;
    });

    // Arrancar la animación sólo cuando ya tenemos la posición
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    // No renderizar nada hasta que tengamos la posición real del botón
    if (!_positionReady) return const SizedBox.shrink();

    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final brightness = Theme.of(context).brightness;

    // Color del bocadillo: usa el primary en dark, superficie acento en light
    final bubbleColor =
        brightness == Brightness.dark
            ? Color.lerp(Theme.of(context).colorScheme.surface, primary, 0.15)!
            : Theme.of(context).colorScheme.surfaceContainerHighest;

    final buttonCenterScreen = _buttonCenterX!;
    final cutoutBottomOffset = _cutoutBottomOffset!;
    const cutoutDiameter = 65.0;

    // El bocadillo tiene que estar justo encima de la barra de navegación.
    // Usamos un Stack principal
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 1. Capa de oscurecimiento con recorte (cutout)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white, // Fondo total de la máscara
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                ),
                Positioned(
                  bottom: cutoutBottomOffset,
                  left: buttonCenterScreen - (cutoutDiameter / 2),
                  width: cutoutDiameter,
                  height: cutoutDiameter,
                  child: Container(
                    decoration: const BoxDecoration(
                      color:
                          Colors
                              .white, // Esto recorta el agujero en la máscara negra
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Bloqueador de toques en el resto de la pantalla
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Absorbe el toque, no permite interactuar con nada debajo
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),

          // 3. Área interactiva únicamente en el botón objetivo
          Positioned(
            bottom: cutoutBottomOffset,
            left: buttonCenterScreen - (cutoutDiameter / 2),
            width: cutoutDiameter,
            height: cutoutDiameter,
            child: GestureDetector(
              onTap: () async {
                await _dismiss();
                widget.onTargetTap();
              },
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),

          // 4. Elementos UI del tutorial (bocadillo y texto inferior)
          SafeArea(
            child: Stack(
              children: [
                // Bocadillo posicionado encima de la barra de navegación
                Positioned(
                  bottom: 72, // encima del BottomAppBar (~72px aprox)
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _bounceAnim,
                        child: ScaleTransition(
                          scale: _scaleAnim,
                          alignment: Alignment.bottomCenter,
                          child: _buildBubble(
                            context,
                            primary: primary,
                            onPrimary: onPrimary,
                            bubbleColor: bubbleColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(
    BuildContext context, {
    required Color primary,
    required Color onPrimary,
    required Color bubbleColor,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEs = locale == 'es';

    final title = isEs ? '¡Empieza aquí!' : 'Start here!';
    final body =
        isEs
            ? 'Crea tus perfiles de arma, cartucho y visor\npara realizar cálculos balísticos precisos.'
            : 'Create your rifle, cartridge and scope profiles\nto perform accurate ballistics calculations.';

    final screenWidth = MediaQuery.of(context).size.width;
    final overlayContentWidth = screenWidth - 48; // 24*2 de padding
    
    // Usar el centro calculado tras el primer frame (ya disponible aquí)
    final buttonCenterScreen = _buttonCenterX ?? screenWidth * 0.625;
    

    final arrowOffset = ((buttonCenterScreen - 24) / overlayContentWidth).clamp(
      0.1,
      0.9,
    );

    return CustomPaint(
      painter: _BubblePainter(
        color: bubbleColor,
        borderColor: primary.withOpacity(0.6),
        arrowOffset: arrowOffset,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: onPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isEs ? 'Tutorial' : 'Tutorial',
                        style: TextStyle(
                          color: onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
