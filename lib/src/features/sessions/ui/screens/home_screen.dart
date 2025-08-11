import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/game_session.dart';
import '../../../sessions/providers/session_provider.dart';
import '../widgets/add_session_sheet.dart';
import '../../../achievements/ui/screens/achievements_screen.dart';
import '../../../statistics/ui/screens/statistics_screen.dart';
import '../../../games/ui/screens/games_library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.secondary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _Header(),
            const SizedBox(height: 8),
            const _QuickActionsRow(),
            const SizedBox(height: 12),
            const _AdviceCard(),
            const SizedBox(height: 12),
            const _ActivityChartCard(),
            const SizedBox(height: 12),
            Expanded(child: const _SessionList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: accent,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Theme.of(context).cardColor,
          builder: (_) => const AddSessionSheet(),
        ),
        label: const Text('Add session'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Color(0xFF0F2239)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'WUNDER',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: const Color(0xFF2CC9FF),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          _Rays(),
        ],
      ),
    );
  }
}

class _Rays extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _RaysPainter(),
        size: Size(MediaQuery.of(context).size.width, 80),
      ),
    );
  }
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF1A3358)
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double top = 0;
    final double bottom = size.height;
    const int rays = 12;
    for (int i = 0; i < rays; i++) {
      final double startX =
          centerX + (i - rays / 2) * (size.width / rays / 1.5);
      final Path path = Path()
        ..moveTo(startX, bottom)
        ..lineTo(startX + size.width / rays / 3, top)
        ..lineTo(startX + size.width / rays / 1.5, bottom)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.tips_and_updates, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tip: Take 5-minute breaks every hour to keep your play healthy.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityChartCard extends StatelessWidget {
  const _ActivityChartCard();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<SessionProvider>().minutesPerDayLast14Days();
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final List<BarChartGroupData> bars = [];

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              width: 12,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    final maxValue = sortedEntries.isEmpty
        ? 0.0
        : sortedEntries
              .map((e) => e.value)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Activity (last 14 days)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue > 0 ? maxValue * 1.2 : 100,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxValue > 0 ? maxValue / 3 : 30,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                          dashArray: [3, 3],
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: maxValue > 0 ? maxValue / 3 : 30,
                          getTitlesWidget: (v, meta) {
                            if (v == 0) return const SizedBox.shrink();
                            return Text(
                              v.toInt().toString(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey, fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 25,
                          getTitlesWidget: (v, meta) {
                            final int i = v.toInt();
                            if (i < 0 || i >= sortedEntries.length) {
                              return const SizedBox.shrink();
                            }
                            final DateTime day = sortedEntries[i].key;
                            final now = DateTime.now();
                            final isToday =
                                day.day == now.day &&
                                day.month == now.month &&
                                day.year == now.year;

                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                DateFormat('E').format(day).substring(0, 2),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: isToday
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.secondary
                                          : Colors.grey,
                                      fontWeight: isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 10,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: bars,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.9),
                        tooltipBorder: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                        ),
                        tooltipRoundedRadius: 6,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex >= 0 &&
                              groupIndex < sortedEntries.length) {
                            final entry = sortedEntries[groupIndex];
                            final dayName = DateFormat('EEE').format(entry.key);
                            final dateStr = DateFormat(
                              'MMM d',
                            ).format(entry.key);
                            return BarTooltipItem(
                              '$dayName\n$dateStr\n${entry.value} min',
                              TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.emoji_events,
              title: 'Achievements',
              subtitle: 'Your rewards',
              color: Colors.amber,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.analytics,
              title: 'Statistics',
              subtitle: 'Detailed analysis',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.library_books,
              title: 'Library',
              subtitle: 'Your games',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GamesLibraryScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList();

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionProvider>().sessions;
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          'No sessions yet. Tap "+" to add.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final s = sessions[index];
        return Dismissible(
          key: ValueKey(s.key),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onDismissed: (_) =>
              context.read<SessionProvider>().deleteSession(index),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                '${DateFormat('MMM d, HH:mm').format(s.startedAt)} • ${s.minutes} min',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _moodLabel(s.mood),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: _moodIcon(s.mood),
            ),
          ),
        );
      },
    );
  }

  String _moodLabel(GameMood mood) {
    switch (mood) {
      case GameMood.great:
        return 'Mood: Great';
      case GameMood.good:
        return 'Mood: Good';
      case GameMood.neutral:
        return 'Mood: Neutral';
      case GameMood.tired:
        return 'Mood: Tired';
      case GameMood.stressed:
        return 'Mood: Stressed';
    }
  }

  Widget _moodIcon(GameMood mood) {
    switch (mood) {
      case GameMood.great:
        return const Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.greenAccent,
        );
      case GameMood.good:
        return const Icon(Icons.sentiment_satisfied, color: Colors.lightGreen);
      case GameMood.neutral:
        return const Icon(Icons.sentiment_neutral, color: Colors.amber);
      case GameMood.tired:
        return const Icon(Icons.sentiment_dissatisfied, color: Colors.orange);
      case GameMood.stressed:
        return const Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.redAccent,
        );
    }
  }
}
