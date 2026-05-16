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


class _HomePageState extends State<HomePage> with WidgetsBindingObserver{
  final ScrollController _scrollController = ScrollController();
  late Store<AppState> _store;
  String _searchquery = '';
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

    @override
  void changapplifcycle(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      savedCharacters(_store.state.items);
    }
    if (state == AppLifecycleState.resumed) {
    }
  }

  void _onscroll(){
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9){
      _store.dispatch(FetchNextPageAction());
    }
  }
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      onInit: (store){
        _store = store;
        _scrollController.addListener(_onscroll);
        store.dispatch(LoadDataAction());
      },
      onDispose: (store){
        _scrollController.removeListener(_onscroll);
      },
      converter: (store) => store.state,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Project')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search here..',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                  onChanged: (value){
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
          )
        );
      },
    );
  }

  Widget _buildBody(AppState state) {
      if (state.error != null) {
    return Center(child: Text('Error: ${state.error}'));
  }
  if (state.items.isEmpty && !state.isLoading) {
    return const Center(child: Text('No characters found.'));
  }
  if (state.items.isEmpty && state.isLoading) {
    return const Center(child: CircularProgressIndicator()); 
  }
  final filteredItems = _searchquery.isEmpty
  ? state.items
  : state.items.where((c) => c.name.toLowerCase().contains(_searchquery)).toList();

  if(filteredItems.isEmpty){
    return const Center(child: Text('No results Found.'),);
  }
    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredItems.length + (state.isLoading?1:0),
      itemBuilder: (context, index) {
        if (index == filteredItems.length) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
        final character = filteredItems[index];
        return InkWell(
          onTap: ()=> Navigator.of(context).push(
            MaterialPageRoute(
              builder: 
              (context) => DetailView(character : character),
              )
            ),
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
                  errorBuilder: (context,error,stackTrace){
                    return Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey,
                      child: const Icon(Icons.person,color: Colors.grey,),
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

