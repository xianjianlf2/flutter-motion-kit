// ✅ Recommended: a SliverAppBar inside a CustomScrollView, with a FlexibleSpaceBar
// whose background parallaxes as the bar collapses to a pinned toolbar.
// The scroll offset drives everything — no AnimationController needed.
// Paste straight into DartPad (https://dartpad.dev) to run.
import 'package:flutter/material.dart';

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

class _Demo extends StatelessWidget {
  const _Demo();

  static const _items = [
    'Overview',
    'Activity',
    'Photos',
    'Files',
    'Members',
    'Settings',
    'Billing',
    'Integrations',
    'Notifications',
    'Security',
    'Advanced',
    'About',
  ];

  @override
  Widget build(BuildContext context) {
    // ✅ A SliverAppBar must live inside a sliver-aware viewport.
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // pinned: keep a collapsed toolbar on screen instead of letting it scroll away.
            pinned: true,
            expandedHeight: 240,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Collapsing header'),
              // ✅ parallax makes the background move slower than the title as it collapses.
              collapseMode: CollapseMode.parallax,
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3F51B5), Color(0xFF7E57C2)],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Icon(
                      Icons.landscape,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ✅ Body shares the same scroll via a SliverList, not a nested ListView.
          SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(_items[i]),
                subtitle: const Text('Scroll up to collapse the header'),
              );
            }, childCount: _items.length),
          ),
        ],
      ),
    );
  }
}
