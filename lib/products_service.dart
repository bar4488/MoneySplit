import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:money_split/product.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductSuggestionService {
  Box productsBox;
  ProductSuggestionService(this.productsBox);

  List<Product> getProductsSuggestion(String suggestion) {
    if (suggestion.isEmpty) return [];
    return List.from(((productsBox.get(suggestion[0]) ?? []) as List).map(
      (e) => Product.fromMap((e as Map).cast<String, dynamic>()),
    ));
  }

  void addSuggestion(Product suggestion) {
    var suggestions = (productsBox.get(suggestion.name[0]) ?? []) as List;
    if (!suggestions.any(
      (element) => mapEquals(
        element.cast<String, dynamic>(),
        suggestion.toMap(),
      ),
    )) {
      suggestions.add(suggestion.toMap());
      productsBox.put(suggestion.name[0], suggestions);
    }
  }

  void removeSuggestion(Product suggestion) {
    List<Map> suggestions = List.castFrom<dynamic, Map>(
        (productsBox.get(suggestion.name[0]) ?? []) as List);
    suggestions.removeWhere(
      (element) => mapEquals(
        element.cast<String, dynamic>(),
        suggestion.toMap(),
      ),
    );
    productsBox.put(suggestion.name[0], suggestions);
  }

  void dispose() {}
}

class ProductService {
  ProductService();

  BehaviorSubject<List<Product>> productsStream = BehaviorSubject.seeded([]);

  addProduct(Product product) {
    // check for duplicated names
    int occurrence = 0;
    String name = product.name;
    while (productsStream.value.any((element) => element.name == name)) {
      occurrence++;
      name = product.name + " ($occurrence)";
    }
    // add to products list
    productsStream.add(productsStream.value..add(product.copyWith(name: name)));
  }

  removeProduct(Product product) {
    productsStream.add(productsStream.value..remove(product));
  }

  void dispose() {
    productsStream.close();
  }
}

class PeopleService {
  SharedPreferences preferences;

  PeopleService(this.preferences) {
    if (preferences.containsKey("people")) {
      peopleStream.add(preferences.getStringList("people"));
    }
  }

  List<String> get people => peopleStream.value;

  BehaviorSubject<List<String>> peopleStream = BehaviorSubject.seeded([]);

  addPerson(String name) {
    peopleStream.add(peopleStream.value..add(name));
    _updateLocalStorage();
  }

  removePerson(String name) {
    peopleStream.add(peopleStream.value..remove(name));
    _updateLocalStorage();
  }

  _updateLocalStorage() async {
    await preferences.setStringList("people", peopleStream.value);
  }

  void dispose() {
    peopleStream.close();
  }
}
