// ✅ Recommended: drive the spring-back with a SpringSimulation via
// animateWith, feeding the release velocity in as the simulation's initial
// velocity. No fixed duration — the physics decides when it settles.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    home: const _Demo(),
  );
}

class _Demo extends StatefulWidget {
  const _Demo();
  @override
  State<_Demo> createState() => _DemoState();
}

// Single controller → SingleTickerProviderStateMixin.
class _DemoState extends State<_Demo> with SingleTickerProviderStateMixin {
  // ✅ No `duration`: animateWith runs the Simulation, so a duration is a no-op.
  late final AnimationController _controller = AnimationController(vsync: this);

  Alignment _dragAlignment = Alignment.center;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    // Each spring tick maps back onto the box's alignment.
    _controller.addListener(() {
      setState(() => _dragAlignment = _animation.value);
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // ✅ release the Ticker to prevent leaks
    super.dispose();
  }

  void _springBack(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(begin: _dragAlignment, end: Alignment.center),
    );

    // Convert the release velocity (px/s) into the Tween's 0..1 unit space.
    final unitsPerSecond = Offset(
      pixelsPerSecond.dx / size.width,
      pixelsPerSecond.dy / size.height,
    );
    final unitVelocity = unitsPerSecond.distance;

    // damping ratio = damping / (2 * sqrt(mass * stiffness)) ≈ 0.60:
    // underdamped enough to feel springy, high enough that it still settles.
    const spring = SpringDescription(mass: 1, stiffness: 200, damping: 17);
    // The Tween runs 0 → 1 toward the centre, so a positive release velocity
    // points *away* from the target — negate it to inject the gesture's energy.
    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);

    // ✅ animateWith drives the controller straight from the simulation.
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Spring drag & release')),
      body: GestureDetector(
        onPanDown: (_) => _controller.stop(),
        onPanUpdate: (details) {
          setState(() {
            _dragAlignment += Alignment(
              details.delta.dx / (size.width / 2),
              details.delta.dy / (size.height / 2),
            );
          });
        },
        // ✅ Hand the pan velocity to the spring so motion continues naturally.
        onPanEnd: (details) =>
            _springBack(details.velocity.pixelsPerSecond, size),
        child: Align(alignment: _dragAlignment, child: const _Box()),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box();
  @override
  Widget build(BuildContext context) => Container(
    width: 120,
    height: 120,
    decoration: BoxDecoration(
      color: Colors.indigo,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(
      child: Text(
        'Drag me',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
