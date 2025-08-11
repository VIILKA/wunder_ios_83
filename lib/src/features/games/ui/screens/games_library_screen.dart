import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/game.dart';
import '../../../../core/models/game_session.dart';
import '../../../sessions/providers/session_provider.dart';
import '../widgets/add_game_sheet.dart';
import '../widgets/game_detail_screen.dart';

class GamesLibraryScreen extends StatefulWidget {
  const GamesLibraryScreen({super.key});

  @override
  State<GamesLibraryScreen> createState() => _GamesLibraryScreenState();
}

class _GamesLibraryScreenState extends State<GamesLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  GameCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Game Library'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Поиск и фильтры
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search games...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<GameCategory?>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (category) =>
                          setState(() => _selectedCategory = category),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...GameCategory.values.map(
                          (category) => PopupMenuItem(
                            value: category,
                            child: Text(_getCategoryName(category)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'My Library', icon: Icon(Icons.library_books)),
                  Tab(text: 'Wishlist', icon: Icon(Icons.favorite)),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GamesList(
            searchQuery: _searchQuery,
            selectedCategory: _selectedCategory,
            showWishlist: false,
          ),
          _GamesList(
            searchQuery: _searchQuery,
            selectedCategory: _selectedCategory,
            showWishlist: true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Theme.of(context).cardColor,
          builder: (_) => const AddGameSheet(),
        ),
        label: const Text('Add Game'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _GamesList extends StatelessWidget {
  const _GamesList({
    required this.searchQuery,
    required this.selectedCategory,
    required this.showWishlist,
  });

  final String searchQuery;
  final GameCategory? selectedCategory;
  final bool showWishlist;

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, child) {
        final games = showWishlist
            ? provider.wishlistGames
            : provider.libraryGames;

        var filteredGames = games.where((game) {
          if (selectedCategory != null && game.category != selectedCategory)
            return false;
          if (searchQuery.isNotEmpty &&
              !game.name.toLowerCase().contains(searchQuery.toLowerCase()))
            return false;
          return true;
        }).toList();

        if (filteredGames.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showWishlist ? Icons.favorite_border : Icons.gamepad,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  showWishlist ? 'Wishlist is empty' : 'Game library is empty',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  showWishlist
                      ? 'Add games you want to play'
                      : 'Add games to your library',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredGames.length,
          itemBuilder: (context, index) {
            final game = filteredGames[index];
            return _GameCard(game: game);
          },
        );
      },
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameDetailScreen(game: game)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Изображение игры или заглушка
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: game.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          game.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(_getCategoryIcon(game.category)),
                        ),
                      )
                    : Icon(_getCategoryIcon(game.category)),
              ),
              const SizedBox(width: 16),

              // Информация об игре
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getCategoryIcon(game.category),
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getCategoryName(game.category),
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!game.isWishlist && game.totalPlayTime > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Played: ${game.formattedPlayTime}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                    if (game.hasRating) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < (game.rating / 2)
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${game.rating}/10',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Действия
              Column(
                children: [
                  if (game.isWishlist)
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        // Remove from wishlist
                      },
                    )
                  else
                    IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        // Quick add session with this game
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
