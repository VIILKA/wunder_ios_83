import 'package:flutter/material.dart';
import '../../../../core/models/game.dart';
import '../../../../core/models/game_session.dart';

class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Красивый app bar с градиентом
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                game.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 3,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: game.imageUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            game.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              _getCategoryIcon(game.category),
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Icon(
                        _getCategoryIcon(game.category),
                        size: 64,
                        color: Colors.white54,
                      ),
              ),
            ),
          ),

          // Основной контент
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Статус и основная информация
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Chip(
                                avatar: Icon(
                                  game.isWishlist
                                      ? Icons.favorite
                                      : Icons.library_books,
                                  size: 18,
                                  color: game.isWishlist
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                                label: Text(
                                  game.isWishlist
                                      ? 'In Wishlist'
                                      : 'In Library',
                                ),
                              ),
                              const Spacer(),
                              if (!game.isWishlist && game.hasRating)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRatingColor(game.rating),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${game.rating}/10',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Информационные строки
                          _InfoRow(
                            icon: _getCategoryIcon(game.category),
                            label: 'Category',
                            value: _getCategoryName(game.category),
                          ),
                          if (game.developer != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.business,
                              label: 'Developer',
                              value: game.developer!,
                            ),
                          ],
                          if (game.platform != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.devices,
                              label: 'Platform',
                              value: game.platform!,
                            ),
                          ],
                          if (game.releaseDate != null) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Release Date',
                              value:
                                  '${game.releaseDate!.day}.${game.releaseDate!.month}.${game.releaseDate!.year}',
                            ),
                          ],
                          if (!game.isWishlist && game.totalPlayTime > 0) ...[
                            const SizedBox(height: 8),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Time Played',
                              value: game.formattedPlayTime,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Рейтинг со звездами (если есть)
                  if (!game.isWishlist && game.hasRating) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Rating',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < (game.rating / 2)
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 32,
                                  );
                                }),
                                const SizedBox(width: 12),
                                Text(
                                  '${game.rating}/10',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Заметки
                  if (game.notes.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              game.notes,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8) return Colors.green;
    if (rating >= 6) return Colors.orange;
    if (rating >= 4) return Colors.red;
    return Colors.grey;
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
