import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../backend/nutrition_http.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _loadingMore = false;
  int _pageNumber = 1;

  late String mealType;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    mealType = arguments['mealType'] as String;
    selectedDate = arguments['selectedDate'] as DateTime;

    return Scaffold(
      appBar: AppBar(
          elevation: 5,
          toolbarHeight: 100,
          backgroundColor: Colors.black,
          title: Stack(
            alignment: Alignment.topRight,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/Logo_Menu_App.png',
                    fit: BoxFit.cover,
                    height: 60,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Light Weight',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'assets/search_icon3.png',
                      height: 25,
                    ),
                    onPressed: () {
                      //do something
                    },
                  ),
                  IconButton(
                    icon: Image.asset(
                      'assets/login_App.png',
                      height: 25,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/start');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
                  const Text(
                    'Food Search',
                    style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for food',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String query = _searchController.text.trim();
                    _loadFoodPage(query);
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length + (_loadingMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == _searchResults.length) {
                    if (_loadingMore) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return SizedBox.shrink();
                    }
                  } else {
                    return ListTile(
                      title: Text(_searchResults[index]['food_name']),
                      subtitle: Text(_searchResults[index]['food_description']),
                      onTap: () {
                        _showFoodDetailPage(_searchResults[index]);
                      },
                    );
                  }
                },
              ),
            ),
            if (_searchResults.isNotEmpty && !_loadingMore)
              ElevatedButton(
                child: Text('Show more results'),
                onPressed: () {
                  setState(() {
                    _loadingMore = true;
                  });
                  String query = _searchController.text.trim();
                  _loadFoodPage(query, loadMore: true);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _loadFoodPage(String query, {bool loadMore = false}) {
    loadFoodPage(
      query,
      _searchResults,
      _loadingMore,
      _pageNumber,
      _searchController,
      (bool loading) {
        setState(() {
          _loadingMore = loading;
        });
      },
      (List<Map<String, dynamic>> results) {
        setState(() {
          _searchResults = results;
        });
      },
      (int number) {
        setState(() {
          _pageNumber = number;
        });
      },
    );
  }

  void _showFoodDetailPage(Map<String, dynamic> foodData) {
    Navigator.pushNamed(
      context,
      '/foodDetailPage',
      arguments: {
        'foodDetails': foodData,
        'mealType': mealType,
        'selectedDate': selectedDate,
      },
    );
  }
}
