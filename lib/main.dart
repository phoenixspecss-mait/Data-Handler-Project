import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project/detail_view.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Character {
  final String name;
  final String image;
  final String species;
  final String status;
  final String gender;
  final String origin;
  Character({
    required this.name, 
    required this.image,
    required this.species,
    required this.status,
    required this.gender,
    required this.origin,
    });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] ?? 'Unknown',
      image: json['image'] ?? '',
      species: json['species'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      origin: json['origin']['name'] ?? 'Unknown',
    );
  }
}


class LoadDataAction {}
class FetchNextPageAction {
}

class LoadDataSuccessAction {
  final List<Character> characters;
  final bool hasMore;
  LoadDataSuccessAction(this.characters,this.hasMore);
}

class LoadDataErrorAction {
  final String error;
  LoadDataErrorAction(this.error);
}


class AppState {
  final List<Character> items;
  final bool isLoading;
  final String? error;
  final int currentpage;
  final bool hasMore;

  AppState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.currentpage = 1,
    this.hasMore = true,
  });
}

AppState appReducer(AppState state, dynamic action) {
  if (action is SearchAction) {
  return AppState(isLoading: true); // clear old list, show spinner
}
  if (action is LoadDataAction) {
    return AppState(isLoading: true);
  } else if(action is FetchNextPageAction){
    return AppState(
      items: state.items,
      isLoading: true,
      currentpage: state.currentpage,
      hasMore: state.hasMore
    );
  }else if (action is LoadDataSuccessAction) {
    return AppState(
      items: [...state.items,...action.characters],
      isLoading: false,
      currentpage: state.currentpage+1,
      hasMore: action.hasMore,
      );
  } else if (action is LoadDataErrorAction) {
    return AppState(
      items: state.items,
      isLoading: false,
      error: action.error,
      currentpage: state.currentpage,
      hasMore: state.hasMore
      );
  }
  return state;
}

void dataMiddleware(Store<AppState> store, action, NextDispatcher next) {
  if (action is LoadDataSuccessAction) {
  savedCharacters(store.state.items); 
}
  if (action is SearchAction) {
  getSearchData(action.query).then((result) {
    store.dispatch(LoadDataSuccessAction(
      result['characters'] as List<Character>,
      result['hasMore'] as bool,
    ));
  }).catchError((error) {
    store.dispatch(LoadDataErrorAction(error.toString()));
  });
}
  if (action is LoadDataAction) {
    getApiData(1).then((result) {
      store.dispatch(LoadDataSuccessAction(
        result['characters'] as List<Character>,
        result['hasMore'] as bool,
        ));
    }).catchError((error) {
      store.dispatch(LoadDataErrorAction(error.toString()));
    });
  }if (action is FetchNextPageAction) {
    if (store.state.isLoading || !store.state.hasMore) return;
    final nextPage = store.state.currentpage + 1;
    getApiData(nextPage).then((result) {
      store.dispatch(LoadDataSuccessAction(
        result['characters'] as List<Character>,
        result['hasMore'] as bool,
      ));
    }).catchError((error) {
      store.dispatch(LoadDataErrorAction(error.toString()));
    });
  }
  next(action);
}
Future<Map<String, dynamic>> getSearchData(String query) async {
  final response = await http.get(
    Uri.parse("https://rickandmortyapi.com/api/character/?name=$query"),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> results = body['results'];
    final bool hasMore = body['info']['next'] != null;
    return {
      'characters': results.map((item) => Character.fromJson(item)).toList(),
      'hasMore': hasMore,
    };
  } else if (response.statusCode == 404) {
    return {'characters': <Character>[], 'hasMore': false}; 
  } else {
    throw Exception('Could not fetch data');
  }
}

Future<void> savedCharacters(List<Character> characters)async{
  final prefs = await SharedPreferences.getInstance();
  final encoded = characters.map((c) => jsonEncode({
    'name' : c.name,
    'image' : c.image,
    'status' : c.status,
    'species' : c.species,
    'gender' : c.gender,
    'origin' : c.origin,
  })).toList();
  await prefs.setStringList('characters', encoded);
}

Future<List<Character>> loadCharacters() async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = prefs.getStringList('characters') ?? [];
  return encoded.map((item) => Character.fromJson(jsonDecode(item))).toList();
}

Future<Map<String,dynamic>> getApiData(int page) async {
  int retries =5;
  while(retries>0){
  final response = await http.get(
    Uri.parse("https://rickandmortyapi.com/api/character?page=$page"),
  );
  if (response.statusCode == 200) {
    final Map<String, dynamic> body = jsonDecode(response.body);
    final List<dynamic> results = body['results'];
    final bool hasMore = body['info']['next'] !=null;
    return {
      'characters' : results.map((item) => Character.fromJson(item)).toList(),
      'hasMore' : hasMore,
    };
  } else if(response.statusCode == 429){
    retries--;
    await Future.delayed(const Duration(seconds: 5));
  }else{
    throw Exception('Could not fetch data');
  }
}
throw Exception('Too many bad requests, try again later');
}
class SearchAction {
  final String query;
  SearchAction(this.query);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  List<Character> savedCharacters = [];
  
  try {
    savedCharacters = await loadCharacters().timeout(
      const Duration(seconds: 3), 
      onTimeout: () => [],
    );
  } catch (e) {
    print('Failed to load saved data: $e');
  }

  final store = Store<AppState>(
    appReducer,
    initialState: AppState(items: savedCharacters),
    middleware: [dataMiddleware],
  );

  runApp(
    StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Project',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomePage(),
      ),
    ),
  );
}