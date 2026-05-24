# Análisis del algoritmo de desviaciones (BallisticsCalculator)

Este documento resume el funcionamiento del algoritmo que calcula las desviaciones balísticas en `lib/services/ballistics_calculator.dart` y enumera posibles errores, condiciones límite y recomendaciones de corrección.

**Resumen**
- Archivo analizado: `lib/services/ballistics_calculator.dart`
- Funciones clave: `calculateWithProfiles`, `calculate`, `_calculateDerivatives`, `calculateLosReference`, `calculateWithFixedLos`.
- Salidas principales: `BallisticsResult` (desviación horizontal/vertical en metros, correcciones en mrad, MOA y unidades lineales).

**Entradas principales**
- `distance` (m)
- `windSpeed` (m/s)
- `windDirection` (grados, 0° = headwind, 90° = left→right)
- `gun` (muzzleVelocity, zeroRange, twistRate, twistDirection)
- `cartridge` (bulletWeight en grains, `diameter` como String, ballisticCoefficient, bcModelType, polynomial ToF coefficients)
- `scope` (sightHeight y unidades)
- `temperature` (°C), `pressure` (mbar o Pa), `humidity` (%), `latitude` (°), `elevationAngle`, `slopeAngle`.

---
**Descripción del algoritmo (pasos)**
1. Validación estricta de perfiles y rangos básicos (distance > 0, ángulos entre -90 y 90, perfiles no nulos).
2. Conversión de presión vía `_convertPressureToPa` (detección heurística entre mbar y Pa).
3. Cálculo de densidad del aire: `calculateAirDensity(tempC, pressurePa, humidity)` usando fórmula de vapor de agua (Tetens) y ley de gases ideales.
4. Extracción de parámetros: masa (conversión grains→kg), diámetro (string → double → metros), coeficiente balístico, velocidad inicial, giro (spinRate), altura del visor.
5. Componentes del viento: lateral (`windSide = windSpeed * sin(windAngle)`) y headwind.
6. Estado inicial e integración RK4 con paso fijo `dt = 0.0001s` hasta un máximo (30 s)
   - Variables integradas: posición (x,y,z), velocidad (vx,vy,vz), spin (p).
   - Derivadas calculadas en `_calculateDerivatives`: gravedad local (función `gravity(lat, alt)`), velocidad relativa al aire, Mach, interpolación de coeficiente de arrastre G1/G7, densidad seccional y factor de forma, fuerza de arrastre, Magnus, lift (por angle-of-attack), yaw-of-repose, efecto de Coriolis, y decadencia de spin.
7. Efecto de wind-jump inicial aplicado como `deltaVy0 = 0.02 * crossWind`, con decaimiento exponencial.
8. Captura de la altura de la bala en el `calibrationDistance` (zeroRange) mediante interpolación segura y guardada como `zAtZero`.
9. Cálculo de la línea de mira (LOS):
   - Si `fixedLosSlope` suministrado, se combina con `elevationAngle`.
   - Si no hay zéro o `gotZero` es false, se aplica fallback estimado (tiempo = D / muzzleVelocity y caída simple 0.5*g*t^2).
   - Si `gotZero` true, se calcula slope dinámico desde `zAtZero` y `visorHeight`.
10. Diferencias: `heightDifference = trajZ - losHeightAtTarget` y `lateralDifference = trajY`.
11. Corrección ToF: adjunta polinomio definido por `cartridge.tofA0..A3`. Si polinomio no es trivial, se aplica factor `adjTof/rawTof` sobre `heightDifference`.
12. Conversión a mrad: `heightDifference / distance * 1000` y `lateralDifference / distance * 1000`.
13. Conversión a MOA (constante `mradToMoa = 1/0.290888`) y cálculo de fracciones/iteraciones (1/20 MRAD, 1/2 MOA, 1/3 MOA etc.).
14. Se retornan todas las variantes en `BallisticsResult`.

---
**Posibles errores, causas y recomendaciones**

1) Entradas nulas o mal formadas
- Síntoma: `ArgumentError` lanzado si `gun`, `cartridge` o `scope` son `null`.
- Recomendación: validar/atratar antes en la UI; proporcionar mensajes al usuario con causa clara.

2) `cartridge.diameter` parseo inseguro
- Problema: `_getDiameterFromCartridge` usa `double.parse(cartridge.diameter)` y puede lanzar `FormatException` si la cadena no es numérica.
- Recomendación: usar `double.tryParse` y proveer valor por defecto o devolver error controlado con mensaje claro.

3) Detección ambigua de unidades de presión
- Problema: `_convertPressureToPa` intenta inferir mbar vs Pa según rangos; rangos 1200–80000 son tratados como Pa con ambigüedad.
- Riesgo: valores mal interpretados (por ejemplo 101325 Pa vs 1013.25 mbar) producirán densidad de aire errónea.
- Recomendación: aceptar parámetro explícito de unidad (p.ej. `pressureUnit`) o forzar la UI a enviar Pa siempre. Añadir logging/warning si el valor cae en rango ambiguo.

4) División por cero al aplicar corrección ToF
- Problema: se calcula `tofFactor = adjTof / rawTof` sin comprobar `rawTof == 0`. Si `timeOfFlight` quedó en 0 (p. ej. si el bucle no avanzó o fue interrumpido), hay división por cero.
- Recomendación: comprobar `rawTof > 0` antes de dividir; si `rawTof` == 0, omitir corrección ToF o usar fallback seguro.

5) Domain error en funciones trigonométricas (asin) y normalizaciones
- Problema: `alpha = asin(liftDirMag / vRelMag)` no protege contra valores ligeramente > 1 por error numérico.
- Recomendación: usar `double ratio = (liftDirMag / vRelMag).clamp(-1.0, 1.0); alpha = asin(ratio);` para evitar NaN.

6) Posibles valores extremos en `tan(losAngle)`
- Problema: si `losAngle` se acerca a +/-90°, `tan(losAngle)` explota y produce valores muy grandes o Infinity.
- Causa: combinación de `elevationAngle` extrema y `losSlope` muy grande (poco probable pero posible con entradas incorrectas).
- Recomendación: validar y limitar `losAngle` en un rango seguro (por ejemplo ±80°) o detectar y reportar entrada inválida.

7) Interpolación de tablas BC fuera de rango
- Problema: `g1DragCoefficient` / `g7DragCoefficient` devuelven `last` si el `mach` excede la tabla. Para machs altos/altísimos se usa el último valor conocido.
- Recomendación: advertir al usuario si el `Mach` sale de la tabla; considerar extrapolación controlada o limitar el cálculo y avisar de incertidumbre.

8) Comentarios y unidades inconsistentes
- Ejemplos: en `_getDiameterFromCartridge` el comentario afirma "Diameter is provided by user in centimeters" y se convierte con `*0.01` (cm→m) lo cual es consistente, pero en `_calculateDerivatives` la conversión `diameterInches = diameter * 39.37` tiene comentario "cm to inches" cuando `diameter` ya está en metros.
- Recomendación: unificar y corregir comentarios; documentar unidades esperadas en los modelos `Cartridge`.

9) Coste computacional / rendimiento
- Problema: paso fijo `dt = 0.0001s` con máximo de 30 s → ~300.000 pasos por simulación; con RK4 y operaciones costosas, cada cálculo puede tardar mucho.
- Recomendación: implementar integrador de paso adaptativo (RK45), permitir `dt` configurables según distancia / ToF, o un criterio de parada temprano (por ejemplo detener cuando `x` supera `distance` y hacer fewer steps). Añadir límite máximo de iteraciones razonable y devolver error si excede.

10) Uso de `print` para debugging
- Problema: en producción se usan muchos `print(...)` que no deberían quedar en la librería (impacto en rendimiento y ruido en logs).
- Recomendación: usar un logger (p.ej. `logging`), y niveles (debug/info/warn/error), o eliminar prints para release.

11) Posible inconsistencia en factores empíricos
- Observación: constantes empíricas como `cm = 0.3`, `qm = 1.15`, `spinDecay = -0.001 * spinMagnitude`, o `deltaVy0 = 0.02 * crossWind` pueden no ajustarse a todas las balas y deben exponerse como parámetros de perfil o documentarse.
- Recomendación: permitir configuración en perfiles `Cartridge`/`Gun` o añadir notas en la UI sobre incerteza empírica.

12) Manejo de errores en generación de tablas
- Problema: `generateBallisticTable` atrapa excepciones por distancia y continúa, solo imprimendo `Error calculating...`.
- Recomendación: propagar errores seleccionables o recolectar un resumen de fallos por distancia para mostrar en UI.

---
**Validaciones adicionales recomendadas**
- Verificar rango de `ballisticCoefficient` y `bulletWeight` ( > 0 ).
- Validar que `muzzleVelocity` sea razonable (p.ej. 100..1200 m/s) y alertar si fuera.
- Proteger contra `NaN` e `Infinity` tras operaciones y abortar con mensaje claro.
- Añadir pruebas unitarias para casos límite: velocidad supersonica, mach>tabla, viento lateral nulo y extremo, slope extremo, zeroRange no alcanzado.

---
**Acciones rápidas (prioritarias)**
- Cambiar `double.parse` → `double.tryParse` en `_getDiameterFromCartridge` y manejar error.
- Proteger `adjTof / rawTof` con `rawTof > 0`.
- Reemplazar `asin(...)` por `asin((...).clamp(-1.0,1.0))`.
- Añadir tiempo límite/iteraciones máximas para la integración y exponer `dt` configurable.
- Añadir advertencia o requerir unidad de presión explícita.

---
Si quieres, aplico los cambios mínimos sugeridos (parches) para:
- Proteger el parseo de diámetro,
- Evitar división por cero en ToF,
- Proteger `asin` con clamp,
- Añadir un `maxSteps` configurable para la integración.

Archivo analizado: `lib/services/ballistics_calculator.dart`.

---
**Errores lógicos y de fórmulas que afectan las mediciones**

El análisis siguiente se centra en errores de lógica o fórmulas dentro de `BallisticsCalculator` que pueden provocar sesgos sistemáticos o mediciones erróneas. Para cada punto indico el posible efecto sobre la medición y una recomendación.

1) Implementación de la fuerza de Magnus (alta severidad)
- Descripción: El cálculo construye una magnitud `magnusMagnitude = 0.5 * rho * A * qm * cm * v^2` y luego multiplica por `magnusX = spinY * vRelZ - spinZ * vRelY` (sin normalizar ni tratar unidades). `magnusX` contiene productos de velocidad y spin (rad/s * m/s), por lo tanto multiplicarlo directamente por una magnitud en Newtons produce una inconsistencia dimensional y un vector de magnitud incorrecta.
- Impacto: Puede generar derivadas laterales (drift) con signo y magnitud incorrectos → errores sistemáticos en correcciones de deriva (mrad/MOA).
- Recomendación: Calcular la dirección del efecto como el vector unitario de `spin × v` (normalizar) y aplicar una escala que incluya la componente de giro (p.ej. depender de `spinMagnitude * diameter / v` u otro factor adimensional). Verificar dimensiones: la fuerza resultante debe tener unidades de Newtons. Exponer los coeficientes empíricos (`cm`, `qm`) y documentarlos.

2) Ambigüedad y unidades del `twistRate` y `spinRate` (alta severidad)
- Descripción: `spinRate` se calcula como `2*pi*muzzleVelocity/(twistRate*diameter)` pero no se especifican unidades de `twistRate` (¿inches por vuelta? ¿calibres/volta?). Comentarios difusos generan valores de spin erróneos.
- Impacto: Spin incorrecto → magnitud de Magnus, yaw-of-repose y deriva serán erróneos.
- Recomendación: Definir explícitamente la unidad de `twistRate` en el modelo `Gun` (p.ej. metros por revolución o pulgadas por revolución) y convertir al SI antes del cálculo.

3) Uso simplista del "form factor" para escalar Cd (media-alta severidad)
- Descripción: Se define `formFactor = sectionalDensity / ballisticCoefficient` y `cd = formFactor * cdModel`. Esto asume una relación lineal simple entre SD/BC y Cd_model sin validar la dimensionalidad ni el rango de aplicación.
- Impacto: Sobre/infraestimación del arrastre, especialmente fuera del rango sub-/trans-/supersónico, causando errores en ToF y caída.
- Recomendación: Revisar la formulación física de la conversión BC→Cd (o exponer `formFactor` y permitir calibración). Añadir comprobaciones para valores extremos de `formFactor`.

4) Extrapolación de tablas G1/G7 fuera de rango (alta severidad para Mach extremos)
- Descripción: Las funciones `g1DragCoefficient` y `g7DragCoefficient` devuelven el último valor si `mach` excede la tabla en vez de advertir o extrapolar apropiadamente.
- Impacto: A Mach muy altos/estratos de transónico la Cd usada será errónea → errores grandes en arrastre y ToF.
- Recomendación: Detectar Mach fuera de rango y devolver error/advertencia, o aplicar extrapolación física razonable con límites y aviso al usuario.

5) Corrección ToF por polinomio aplicada como factor multiplicativo (media severidad)
- Descripción: Se calcula `adjTof = a0 + a1*raw + a2*raw^2 + a3*raw^3` y se aplica `heightDifference *= adjTof/rawTof`. Si `a0 != 1` y todos los demás coeficientes son 0 el código actualmente no aplica la corrección (condición `if (a1!=0||a2!=0||a3!=0)`). Además, la corrección por ToF mediante un factor multiplicativo directo no está justificada físicamente en todos los casos.
- Impacto: Aplicar o no aplicar la corrección de forma inconsistente puede introducir sesgos en el ajuste vertical.
- Recomendación: 1) Aplicar la corrección si `rawTof>0` y `adjTof` es numéricamente válida; 2) documentar la base física del ajuste o usar un método alternativo (p.ej. ajustar la velocidad inicial o modelar el drag con parámetros ajustados por perfil y no con un multiplicador arbitrario).

6) División por cero / ToF = 0 (alta probabilidad de excepción)
- Descripción: Si `timeOfFlight` es 0 (por fallo de integración) se produce división al calcular `tofFactor` o efectos derivados.
- Impacto: Crash o NaN en resultados.
- Recomendación: Comprobar `rawTof > eps` antes de dividir; si `rawTof` es ~0, usar fallback seguro o marcar la corrida como inválida.

7) Uso de `asin` sin clamp (posible NaN)
- Descripción: `alpha = asin(liftDirMag / vRelMag)` puede recibir argumentos ligeramente >1 por errores numéricos.
- Impacto: NaN propagado en cálculos → resultados inválidos.
- Recomendación: Usar `clamp(-1.0, 1.0)` antes de `asin`.

8) Unidades inconsistentes y comentarios confusos (media severidad)
- Descripción: Comentarios como "cm to inches" o la conversión `diameter * 39.37` confunden si `diameter` está en m. Small mismatches pueden introducir errores de escala.
- Impacto: Errores de factor 2× o 10× en área/SD/CD si se usan unidades equivocadas.
- Recomendación: Documentar unidades esperadas en `Cartridge` y en cada variable local; usar constantes globales bien nombradas (`M_TO_INCH = 39.3700787`).

9) Wind-jump y signo de convención del viento (media severidad)
- Descripción: `deltaVy0 = 0.02 * crossWind` y comentarios indican que bullet jumps "TOWARDS the wind" para twist RH. La convención de signos de `windDirection` y `crossWind` debe estar explicitada.
- Impacto: Si el signo está invertido en la UI o en la interpretación del usuario, la corrección de deriva se mostrará en la dirección opuesta.
- Recomendación: Añadir documentación clara de la convención (ej.: `windDirection` 0°=headwind, 90°=left→right) y tests unitarios que verifiquen dirección de desviación para casos sencillos.

10) Integración numérica y acumulación de error (media severidad)
- Descripción: Paso de integración fijo muy pequeño (`dt=1e-4`) produce muchos pasos y posible acumulación de error y coste computacional. No hay control de error local (paso adaptativo).
- Impacto: Posibles errores numéricos acumulados y tiempos de cálculo largos que incentivan reducir `dt` manualmente, con riesgo de estabilidad.
- Recomendación: Implementar un integrador con paso adaptativo (RK45) o exponer `dt` y un `maxSteps`/tolerance configurable. Registrar si la integración alcanza `maxSteps`.

11) Coriolis y descomposición del vector de rotación (baja-media severidad)
- Descripción: La construcción de los componentes de `omega` y la fórmula de coriolis parecen coherentes pero dependen fuertemente del sistema de ejes definido (shooting plane axes). Si las definiciones de ejes cambian, el signo podría invertirse.
- Impacto: Sesgo sistemático en deriva para largas distancias (pocos mrad pero acumulables).
- Recomendación: Documentar claramente el sistema de coordenadas y añadir tests que comparen con casos analíticos (p.ej. bala sin viento a latitudes opuestas).

12) Fallback de zero-range usando caída simple (potencial sesgo)
- Descripción: Si no se captura `zAtZero`, el fallback usa una caída estimada `0.5*g*t^2` con `t = calibrationDistance / muzzleVelocity`. Esto ignora arrastre y puede sobreestimar la altura en cero.
- Impacto: Línea de mira estimada erróneamente → errores sistemáticos en la corrección vertical.
- Recomendación: En lugar de usar una caída sin arrastre, simular con condiciones simplificadas (p.ej. integrar con paso más grueso solo hasta el zeroRange) o requerir que `zeroRange` sea válido para perfiles guardados.

---
Si quieres, aplico parches que implementen las correcciones menos invasivas (clamp en `asin`, protección en ToF, `double.tryParse`, check Mach fuera de rango y advertencias, y añadir `maxSteps`). También puedo añadir tests unitarios que cubran los casos señalados.

Fin del análisis ampliado.
