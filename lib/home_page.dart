import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:project/detail_view.dart';
import 'package:redux/redux.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late Store<AppState> _store;
  String _searchquery = '';

  // 1. ADD THIS: A simple dictionary for your app's text
  String _translate(String key, String language) {
    const translations = {
      'English': {
        'title': 'Project',
        'search': 'Search here..',
        'error': 'Error:',
        'no_chars': 'No characters found.',
        'no_results': 'No results Found.',
      },
      'Spanish': {
        'title': 'Proyecto',
        'search': 'Buscar aquí..',
        'error': 'Error:',
        'no_chars': 'No se encontraron personajes.',
        'no_results': 'No se encontraron resultados.',
      },
      'Hindi': {
        'title': 'प्रोजेक्ट',
        'search': 'यहाँ खोजें..',
        'error': 'त्रुटि:',
        'no_chars': 'कोई पात्र नहीं मिला.',
        'no_results': 'कोई परिणाम नहीं मिला.',
      }
    };

    // Return the translated word, or default to English if something goes wrong
    return translations[language]?[key] ?? translations['English']![key]!;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  // 2. FIX: Corrected the built-in Flutter observer method name
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      savedCharacters(_store.state.items);
    }
  }

  void _onscroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _store.dispatch(FetchNextPageAction());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      onInit: (store) {
        _store = store;
        _scrollController.addListener(_onscroll);
        store.dispatch(LoadDataAction());
      },
      onDispose: (store) {
        _scrollController.removeListener(_onscroll);
      },
      converter: (store) => store.state,
      builder: (context, state) {
        return Scaffold(
          // 3. USE TRANSLATION: Update title
          appBar: AppBar(title: Text(_translate('title', state.language))),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    // 4. USE TRANSLATION: Update search hint
                    hintText: _translate('search', state.language),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchquery = value.toLowerCase();
                    });
                    if (value.length >= 2) {
                      _store.dispatch(SearchAction(value));
                    } else if (value.isEmpty) {
                      _store.dispatch(LoadDataAction());
                    }
                  },
                ),
              ),
              Expanded(child: _buildBody(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AppState state) {
    if (state.error != null) {
      // 5. USE TRANSLATION: Update error text
      return Center(
          child: Text('${_translate('error', state.language)} ${state.error}'));
    }
    if (state.items.isEmpty && !state.isLoading) {
      // 6. USE TRANSLATION: Update empty state text
      return Center(child: Text(_translate('no_chars', state.language)));
    }
    if (state.items.isEmpty && state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final filteredItems = _searchquery.isEmpty
        ? state.items
        : state.items
            .where((c) => c.name.toLowerCase().contains(_searchquery))
            .toList();

    if (filteredItems.isEmpty) {
      // 7. USE TRANSLATION: Update empty search text
      return Center(
        child: Text(_translate('no_results', state.language)),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredItems.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredItems.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final character = filteredItems[index];
        return InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DetailView(character: character),
          )),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  character.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey,
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              title: Text(character.name),
            ),
          ),
        );
      },
    );
  }
}