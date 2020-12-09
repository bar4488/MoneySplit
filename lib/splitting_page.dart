import 'package:flutter/material.dart';
import 'package:money_split/keep_alive.dart';
import 'package:money_split/main.dart';
import 'package:money_split/money_split_result.dart';
import 'package:money_split/product.dart';
import 'package:money_split/product_item.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class SplittingPage extends StatefulWidget {
  SplittingPage({Key key}) : super(key: key);

  @override
  _SplittingPageState createState() => _SplittingPageState();
}

class _SplittingPageState extends State<SplittingPage> {
  List<Product> products = List();
  List<String> people = List();
  Map<Product, List<String>> shoppingCart = Map();
  String name, nameError;
  PageController controller = PageController();
  SharedPreferences preferences;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void initialize() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      people = preferences.getStringList("people") ?? [];
    });
  }

  void addPerson() {
    nameError = null;
    setState(() {
      name = name.trim();
      if (name == null || name.isEmpty) {
        nameError = "name cannot be empty";
        return;
      }
      if (people.contains(name)) {
        nameError = "name must be unique";
        return;
      }

      people.add(name);
      updatePeoplePreferences();
    });
  }

  void updatePeoplePreferences() async {
    await preferences.setStringList("people", people);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Money Split"),
      ),
      body: PageView(
        controller: controller,
        children: [
          ProductListPage(products: products, onChange: () => setState(() {})),
          if (products.length != 0) buildPeopleList(),
          if (people.length != 0)
            KeepAlivePage(
              child: buildProductsList(),
            ),
        ],
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () => nextStage(context),
          tooltip: 'Done',
          child: Icon(Icons.check),
        );
      }),
    );
  }

  void nextStage(BuildContext context) {
    if (controller.page == 2) {
      Map<String, double> peoplesMoney = Map();
      for (MapEntry<Product, List<String>> entry in shoppingCart.entries) {
        for (String name in entry.value) {
          peoplesMoney.putIfAbsent(name, () => 0);
          peoplesMoney[name] += entry.key.totalPrice / entry.value.length;
        }
      }
      showGeneralDialog(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) {
            return SafeArea(
              child: Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: MoneySplitResult(peoplesMoney),
              ),
            );
          },
          transitionDuration: Duration(milliseconds: 200));
    } else {
      controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  Widget buildProductsList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < products.length; i++)
            buildProductItem(products[i])
        ],
      ),
    );
  }

  ProductItem buildProductItem(Product product) {
    if (shoppingCart[product] == null) {
      shoppingCart[product] = List();
    }
    return ProductItem(
      people: people,
      product: product,
      checkedPeople: shoppingCart[product],
    );
  }

  Center buildPeopleList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: "Name",
                errorText: nameError,
              ),
              textDirection: intl.Bidi.startsWithRtl(name ?? "")
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            TextButton(onPressed: addPerson, child: Text("Add")),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    for (int i = 0; i < people.length; i++)
                      Container(
                        child: buildPerson(people[i]),
                      ),
                    SizedBox(
                      height: 60,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProduct(Product product) {
    return Container(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text("Price: ${product.price}"),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => setState(() => products.remove(product)),
        ),
      ),
    );
  }

  Widget buildPerson(String name) {
    print(Colors.primaries.length);
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors
              .primaries[people.indexOf(name) * 5 % Colors.primaries.length],
        ),
        title: Text(name),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => setState(() {
            people.remove(name);
            updatePeoplePreferences();
          }),
        ),
      ),
    );
  }
}
