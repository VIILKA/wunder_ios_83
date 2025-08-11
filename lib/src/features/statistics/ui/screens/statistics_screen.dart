import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/game_session.dart';
import '../../../sessions/providers/session_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.analytics)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
            Tab(text: 'Mood', icon: Icon(Icons.sentiment_satisfied)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GeneralStatsTab(),
          _CategoryStatsTab(),
          _MoodStatsTab(),
        ],
      ),
    );
  }
}

class _GeneralStatsTab extends StatelessWidget {
  const _GeneralStatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final sessions = provider.sessions;
        final todayMinutes = provider.totalMinutesToday();
        final weekMinutes = provider.totalMinutesThisWeek();
        final averageSession = provider.getAverageSessionLength();
        final longestSession = provider.getLongestSession();
        final streakDays = provider.streakDays;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main metrics
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Today',
                      value: '${todayMinutes}m',
                      subtitle: 'minutes played',
                      icon: Icons.today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'This Week',
                      value: '${weekMinutes}m',
                      subtitle: 'minutes played',
                      icon: Icons.calendar_view_week,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Streak Days',
                      value: '$streakDays',
                      subtitle: 'consecutive days',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Total Sessions',
                      value: '${sessions.length}',
                      subtitle: 'gaming sessions',
                      icon: Icons.sports_esports,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Average Time',
                      value: '${averageSession.toInt()}m',
                      subtitle: 'average session',
                      icon: Icons.timer,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Longest',
                      value: longestSession != null
                          ? '${longestSession.minutes}m'
                          : '0m',
                      subtitle: 'session',
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Activity chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity (Last 14 Days)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _ActivityChart(
                          data: provider.minutesPerDayLast14Days(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Goals
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Progress',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _GoalProgress(
                        title: 'Daily Goal',
                        current: todayMinutes,
                        target: provider.settings.dailyGoalMinutes,
                        progress: provider.dailyGoalProgress,
                      ),
                      const SizedBox(height: 12),
                      _GoalProgress(
                        title: 'Weekly Goal',
                        current: weekMinutes,
                        target: provider.settings.weeklyGoalMinutes,
                        progress: provider.weeklyGoalProgress,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryStatsTab extends StatelessWidget {
  const _CategoryStatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final categoryData = provider.minutesPerCategory();
        final totalMinutes = categoryData.values.fold<int>(
          0,
          (sum, val) => sum + val,
        );

        if (categoryData.isEmpty) {
          return const Center(child: Text('No category data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pie chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Distribution by Categories',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _createPieChartSections(
                              categoryData,
                              totalMinutes,
                              context,
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categories list
              ...categoryData.entries.map((entry) {
                final percentage = totalMinutes > 0
                    ? (entry.value / totalMinutes * 100).toInt()
                    : 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(_getCategoryIcon(entry.key)),
                    title: Text(
                      _getCategoryName(entry.key),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${entry.value} minutes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<GameCategory, int> data,
    int total,
    BuildContext context,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
    ];

    int colorIndex = 0;
    return data.entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: percentage,
        title: '${percentage.toInt()}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _MoodStatsTab extends StatelessWidget {
  const _MoodStatsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final moodData = provider.sessionsPerMood();

        if (moodData.isEmpty) {
          return const Center(child: Text('No mood data available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood During Gaming',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ...moodData.entries.map((entry) {
                        final total = moodData.values.fold<int>(
                          0,
                          (sum, val) => sum + val,
                        );
                        final percentage = total > 0
                            ? (entry.value / total * 100).toInt()
                            : 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              _getMoodIcon(entry.key),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getMoodName(entry.key),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: Colors.grey.withOpacity(
                                        0.3,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        _getMoodColor(entry.key),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value} ($percentage%)',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getMoodIcon(GameMood mood) {
    switch (mood) {
      case GameMood.great:
        return const Icon(Icons.sentiment_very_satisfied, color: Colors.green);
      case GameMood.good:
        return const Icon(Icons.sentiment_satisfied, color: Colors.lightGreen);
      case GameMood.neutral:
        return const Icon(Icons.sentiment_neutral, color: Colors.amber);
      case GameMood.tired:
        return const Icon(Icons.sentiment_dissatisfied, color: Colors.orange);
      case GameMood.stressed:
        return const Icon(Icons.sentiment_very_dissatisfied, color: Colors.red);
    }
  }

  String _getMoodName(GameMood mood) {
    switch (mood) {
      case GameMood.great:
        return 'Great';
      case GameMood.good:
        return 'Good';
      case GameMood.neutral:
        return 'Neutral';
      case GameMood.tired:
        return 'Tired';
      case GameMood.stressed:
        return 'Stressed';
    }
  }

  Color _getMoodColor(GameMood mood) {
    switch (mood) {
      case GameMood.great:
        return Colors.green;
      case GameMood.good:
        return Colors.lightGreen;
      case GameMood.neutral:
        return Colors.amber;
      case GameMood.tired:
        return Colors.orange;
      case GameMood.stressed:
        return Colors.red;
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.data});

  final Map<DateTime, int> data;

  @override
  Widget build(BuildContext context) {
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
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
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

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue > 0 ? maxValue * 1.2 : 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxValue > 0 ? maxValue / 4 : 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
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
              reservedSize: 35,
              interval: maxValue > 0 ? maxValue / 4 : 25,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              getTitlesWidget: (value, meta) {
                final int i = value.toInt();
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isToday
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
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
            getTooltipColor: (group) =>
                Theme.of(context).colorScheme.surface.withOpacity(0.9),
            tooltipBorder: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= 0 && groupIndex < sortedEntries.length) {
                final entry = sortedEntries[groupIndex];
                final dayName = DateFormat('EEEE').format(entry.key);
                final dateStr = DateFormat('MMM d').format(entry.key);
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
    );
  }
}

class _GoalProgress extends StatelessWidget {
  const _GoalProgress({
    required this.title,
    required this.current,
    required this.target,
    required this.progress,
  });

  final String title;
  final int current;
  final int target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            Text(
              '$current / $target min',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0
                ? Colors.green
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

IconData _getCategoryIcon(GameCategory category) {
  switch (category) {
    case GameCategory.action:
      return Icons.flash_on;
    case GameCategory.adventure:
      return Icons.explore;
    case GameCategory.strategy:
      return Icons.psychology;
    case GameCategory.rpg:
      return Icons.person;
    case GameCategory.sports:
      return Icons.sports_soccer;
    case GameCategory.puzzle:
      return Icons.extension;
    case GameCategory.simulation:
      return Icons.sim_card;
    case GameCategory.other:
      return Icons.games;
  }
}

String _getCategoryName(GameCategory category) {
  switch (category) {
    case GameCategory.action:
      return 'Action';
    case GameCategory.adventure:
      return 'Adventure';
    case GameCategory.strategy:
      return 'Strategy';
    case GameCategory.rpg:
      return 'RPG';
    case GameCategory.sports:
      return 'Sports';
    case GameCategory.puzzle:
      return 'Puzzle';
    case GameCategory.simulation:
      return 'Simulation';
    case GameCategory.other:
      return 'Other';
  }
}
