import 'package:flutter/material.dart';
import 'package:money_split/add_products_page.dart';
import 'package:money_split/money_split_result.dart';
import 'package:money_split/product.dart';
import 'package:money_split/product_item.dart';
import 'package:intl/intl.dart' as intl;
import 'package:money_split/products_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplittingPage extends StatefulWidget {
  SplittingPage({Key key}) : super(key: key);

  @override
  _SplittingPageState createState() => _SplittingPageState();
}

class _SplittingPageState extends State<SplittingPage> {
  Map<Product, List<String>> shoppingCart = Map();
  String name, nameError;
  PageController controller = PageController();
  SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
  }

  void addPerson() {
    nameError = null;
    PeopleService service = context.read();
    setState(() {
      name = name.trim();
      if (name == null || name.isEmpty) {
        nameError = "name cannot be empty";
        return;
      }
      if (service.people.contains(name)) {
        nameError = "name must be unique";
        return;
      }

      service.addPerson(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Money Split"),
      ),
      body: StreamBuilder<List<Product>>(
          stream: context.select((ProductService s) => s.productsStream),
          builder: (context, products) {
            return StreamBuilder<List<String>>(
                stream: context.select((PeopleService s) => s.peopleStream),
                builder: (context, people) {
                  return PageView(
                    controller: controller,
                    children: [
                      ProductListPage(),
                      if (products.hasData && products.data.length != 0) ...[
                        buildPeopleList(),
                        if (people.hasData && people.data.length != 0)
                          buildProductsList(products.data)
                      ],
                    ],
                  );
                });
          }),
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

  Widget buildProductsList(List<Product> products) {
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
                child: StreamBuilder<List<String>>(
                    stream: context.read<PeopleService>().peopleStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      return Column(
                        children: [
                          for (int i = 0; i < snapshot.data.length; i++)
                            Container(
                              child: buildPerson(snapshot.data[i]),
                            ),
                          SizedBox(
                            height: 60,
                          )
                        ],
                      );
                    }),
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
          onPressed: () => setState(
              () => context.read<ProductService>().removeProduct(product)),
        ),
      ),
    );
  }

  Widget buildPerson(String name) {
    print(Colors.primaries.length);
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.primaries[
              context.read<PeopleService>().people.indexOf(name) *
                  5 %
                  Colors.primaries.length],
        ),
        title: Text(name),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => setState(() {
            context.read<PeopleService>().removePerson(name);
          }),
        ),
      ),
    );
  }
}
