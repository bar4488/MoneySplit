import 'package:flutter/material.dart';
import 'package:money_split/product.dart';
import 'package:money_split/splitting_page.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Split',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplittingPage(),
    );
  }
}

class ProductListPage extends StatefulWidget {
  ProductListPage({Key key, this.products, this.onChange}) : super(key: key);

  final List<Product> products;
  final Function() onChange;

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String price, product, amount;
  String priceError, productError, amountError;

  List<Product> get products => widget.products;

  void addItem() {
    priceError = null;
    productError = null;
    amountError = null;
    double doublePrice;
    int intAmount;
    setState(() {
      if (price == null) {
        priceError = "price cannot be empty";
      } else {
        doublePrice = double.tryParse(price);
        if (doublePrice == null) {
          priceError = "not a valid number";
        }
      }
      intAmount = amount != null ? int.tryParse(amount) ?? 1 : 1;

      if (product == null || product.isEmpty) {
        productError = "product cannot be empty";
      } else if (intAmount != null && doublePrice != null) {
        products
            .add(Product(name: product, price: doublePrice, amount: intAmount));
        widget.onChange();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: "Product",
                errorText: productError,
              ),
              textInputAction: TextInputAction.next,
              textDirection: intl.Bidi.startsWithRtl(product ?? "")
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              onChanged: (value) {
                setState(() {
                  product = value;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Price",
                      errorText: priceError,
                    ),
                    textInputAction: TextInputAction.next,
                    textDirection: intl.Bidi.startsWithRtl(price ?? "")
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    onChanged: (value) {
                      setState(() {
                        price = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Amount",
                      errorText: amountError,
                    ),
                    textDirection: intl.Bidi.startsWithRtl(amount ?? "")
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    onChanged: (value) {
                      setState(() {
                        amount = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            TextButton(onPressed: addItem, child: Text("Add")),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    for (int i = 0; i < products.length; i++)
                      Container(
                        child: buildProduct(products[i]),
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
        subtitle: Text("Price: ${product.price}, Amount: ${product.amount}"),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => setState(() {
            products.remove(product);
            widget.onChange();
          }),
        ),
      ),
    );
  }
}
