// ✅ Recommended: a single controller drives the ShaderMask sweep; reuse the child and isolate repaints with RepaintBoundary.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true),
    home: const _Demo(),
  );
}

class _Demo extends StatelessWidget {
  const _Demo();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading…')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        // Isolate each skeleton tile's repaints independently
        itemBuilder: (_, __) => const RepaintBoundary(child: _SkeletonTile()),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: _Shimmer(
        child: Row(
          children: [
            _Box(width: 56, height: 56, radius: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(width: 160, height: 14, radius: 6),
                  SizedBox(height: 10),
                  _Box(width: 240, height: 12, radius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, required this.radius});
  final double width, height, radius;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white, // the ShaderMask takes over the color
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});
  final Widget child;
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget
          .child, // the skeleton shape doesn't change per frame -> reuse it as the child
      builder: (context, child) {
        final dx = _controller.value * 2 - 1; // sweeps from -1 -> 1
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-1 + dx, 0),
            end: Alignment(1 + dx, 0),
            colors: const [
              Color(0xFF2A2F37),
              Color(0xFF454C59),
              Color(0xFF2A2F37),
            ],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}
