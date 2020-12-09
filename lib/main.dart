import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_split/products_service.dart';
import 'package:money_split/splitting_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferencesService;
Box productsSuggestionsBox;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    () async {
      preferencesService = await SharedPreferences.getInstance();
    }(),
    () async {
      await Hive.initFlutter();
      productsSuggestionsBox = await Hive.openBox("products");
    }()
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: preferencesService),
        Provider(create: (context) => ProductService()),
        Provider(
          create: (context) => ProductSuggestionService(productsSuggestionsBox),
        ),
        Provider(
          create: (context) => PeopleService(preferencesService),
        )
      ],
      child: MaterialApp(
        title: 'Money Split',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplittingPage(),
      ),
    );
  }
}
