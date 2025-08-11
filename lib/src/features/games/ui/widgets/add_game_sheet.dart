import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/game.dart';
import '../../../../core/models/game_session.dart';
import '../../../sessions/providers/session_provider.dart';

class AddGameSheet extends StatefulWidget {
  const AddGameSheet({super.key});

  @override
  State<AddGameSheet> createState() => _AddGameSheetState();
}

class _AddGameSheetState extends State<AddGameSheet> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _developerController = TextEditingController();
  final _platformController = TextEditingController();

  GameCategory _category = GameCategory.other;
  double _rating = 0.0;
  bool _isWishlist = false;
  DateTime? _releaseDate;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _developerController.dispose();
    _platformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Хэндл
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Заголовок
            Center(
              child: Text(
                'Add Game',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),

            // Переключатель: Библиотека / Список желаний
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _isWishlist ? Icons.favorite : Icons.library_books,
                      color: _isWishlist
                          ? Colors.red
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isWishlist ? 'Add to Wishlist' : 'Add to Library',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Switch(
                      value: _isWishlist,
                      onChanged: (value) => setState(() => _isWishlist = value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Название игры
            _Field(
              label: 'Game Name',
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Enter game name'),
              ),
            ),
            const SizedBox(height: 12),

            // Категория
            _Field(
              label: 'Category',
              child: DropdownButtonFormField<GameCategory>(
                value: _category,
                decoration: const InputDecoration(hintText: 'Select category'),
                items: GameCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(category)),
                        const SizedBox(width: 8),
                        Text(_getCategoryName(category)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Рейтинг (только если не wishlist)
            if (!_isWishlist) ...[
              _Field(
                label: 'Rating (0-10)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      value: _rating,
                      max: 10,
                      divisions: 20,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0', style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '10',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Разработчик
            _Field(
              label: 'Developer (optional)',
              child: TextField(
                controller: _developerController,
                decoration: const InputDecoration(
                  hintText: 'Developer studio name',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Платформа
            _Field(
              label: 'Platform (optional)',
              child: TextField(
                controller: _platformController,
                decoration: const InputDecoration(
                  hintText: 'PC, PlayStation, Xbox, Switch...',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Дата выхода
            _Field(
              label: 'Release Date (optional)',
              child: OutlinedButton.icon(
                onPressed: _pickReleaseDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _releaseDate != null
                      ? '${_releaseDate!.day}.${_releaseDate!.month}.${_releaseDate!.year}'
                      : 'Select date',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Заметки
            _Field(
              label: 'Notes',
              child: TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Your thoughts about this game...',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReleaseDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _releaseDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 5),
      ), // 5 лет в будущее
    );
    if (date != null) {
      setState(() => _releaseDate = date);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter game name')));
      return;
    }

    final game = Game(
      name: name,
      category: _category,
      rating: _isWishlist ? 0.0 : _rating,
      notes: _notesController.text.trim(),
      isWishlist: _isWishlist,
      developer: _developerController.text.trim().isEmpty
          ? null
          : _developerController.text.trim(),
      platform: _platformController.text.trim().isEmpty
          ? null
          : _platformController.text.trim(),
      releaseDate: _releaseDate,
    );

    await context.read<SessionProvider>().addGame(game);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWishlist ? 'Game added to wishlist!' : 'Game added to library!',
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        child,
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
