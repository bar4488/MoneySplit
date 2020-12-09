import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:money_split/product.dart';
import 'package:intl/intl.dart' as intl;
import 'package:money_split/products_service.dart';
import 'package:provider/provider.dart';

class ProductListPage extends StatefulWidget {
  ProductListPage({Key key}) : super(key: key);

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  String amount;
  String priceError, productError, amountError;

  SuggestionsBoxController controller = SuggestionsBoxController();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void addItem() {
    priceError = null;
    productError = null;
    amountError = null;
    double doublePrice;
    int intAmount;
    setState(() {
      var name = nameController.text;
      var price = priceController.text;
      if (price == null) {
        priceError = "price cannot be empty";
      } else {
        doublePrice = double.tryParse(price);
        if (doublePrice == null) {
          priceError = "not a valid number";
        }
      }
      intAmount = amount != null ? int.tryParse(amount) ?? 1 : 1;

      if (name == null || name.isEmpty) {
        productError = "product cannot be empty";
      } else if (intAmount != null && doublePrice != null) {
        var product = Product(
          name: nameController.text,
          price: doublePrice,
          amount: intAmount,
        );
        context.read<ProductSuggestionService>().addSuggestion(product);
        context.read<ProductService>().addProduct(product);
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
            TypeAheadField(
              suggestionsBoxController: controller,
              textFieldConfiguration: TextFieldConfiguration(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Product",
                  errorText: productError,
                ),
                textInputAction: TextInputAction.next,
                textDirection:
                    intl.Bidi.startsWithRtl(nameController.text ?? "")
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              suggestionsCallback: (value) async {
                var suggestions = context
                    .read<ProductSuggestionService>()
                    .getProductsSuggestion(value);
                return suggestions;
              },
              noItemsFoundBuilder: (context) => null,
              itemBuilder: (context, itemData) {
                Product product = itemData;
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.price.toStringAsFixed(2)),
                  dense: true,
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      context
                          .read<ProductSuggestionService>()
                          .removeSuggestion(product);
                      nameController.text = nameController.text
                          .substring(0, nameController.text.length - 1);
                    },
                  ),
                );
              },
              onSuggestionSelected: (suggestion) {
                Product product = suggestion;
                nameController.text = product.name;
                priceController.text = product.price.toStringAsFixed(2);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: "Price",
                      errorText: priceError,
                    ),
                    textInputAction: TextInputAction.next,
                    textDirection:
                        intl.Bidi.startsWithRtl(priceController.text ?? "")
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    onChanged: (value) {
                      setState(() {});
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
                child: StreamBuilder<List<Product>>(
                    stream: context
                        .select((ProductService value) => value.productsStream),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
                          if (snapshot.hasData)
                            for (int i = 0; i < snapshot.data.length; i++)
                              Container(
                                child: buildProduct(snapshot.data[i]),
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
        subtitle: Text("Price: ${product.price}, Amount: ${product.amount}"),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => setState(() {
            context.read<ProductService>().removeProduct(product);
          }),
        ),
      ),
    );
  }
}
