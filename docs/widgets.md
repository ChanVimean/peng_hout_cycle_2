### Custom Widgets

**Quick Navigation**

- [Enum - App State](#enum---app-state)

---

### Enum - App State

> `core/widgets/app_search_suggestion_bar.dart`

```dart
/// Google-Maps-style search pill that shows tappable suggestions below it.
/// Generic: pass any item list + how to render and handle taps.
class AppSearchSuggestionBar<T> extends StatelessWidget {
  const AppSearchSuggestionBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.query,
    required this.suggestions,
    required this.itemBuilder,
    required this.onChanged,
    required this.onSelected,
    required this.onClear,
    this.maxSuggestions = 5,
  });

  final TextEditingController controller;
  final String hint;
  final String query;
  final List<T> suggestions;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ValueChanged<String> onChanged;
  final ValueChanged<T> onSelected;
  final VoidCallback onClear;
  final int maxSuggestions;

  @override
  Widget build(BuildContext context) {
    final visible = suggestions.take(maxSuggestions).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── the search field row ──
            SizedBox(
              height: 52,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                        ),
                        onChanged: onChanged,
                      ),
                    ),
                    if (query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: onClear,
                      )
                    else
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.person, size: 18),
                      ),
                  ],
                ),
              ),
            ),

            // ── suggestion list, only while typing ──
            if (query.isNotEmpty && visible.isNotEmpty) ...[
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visible.length,
                itemBuilder: (context, i) => InkWell(
                  onTap: () => onSelected(visible[i]),
                  child: itemBuilder(context, visible[i]),
                ),
              ),
            ],
            if (query.isNotEmpty && visible.isEmpty) ...[
              const Divider(height: 1),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No results', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---
