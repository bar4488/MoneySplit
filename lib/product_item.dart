import 'package:flutter/material.dart';
import 'package:money_split/product.dart';
import 'package:money_split/products_service.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatefulWidget {
  ProductItem({Key key, this.product, this.checkedPeople}) : super(key: key);

  final Product product;
  final List<String> checkedPeople;

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem>
    with SingleTickerProviderStateMixin {
  bool editing = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Row(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: widget.checkedPeople.isEmpty ? 6 : 0,
                        height: widget.checkedPeople.isEmpty ? 6 : 0,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: widget.checkedPeople.isEmpty ? 8 : 0,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(widget.product.name),
                          if (widget.product.amount != 1) ...[
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              "x" + widget.product.amount.toString(),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text(
                      "Total price: ${widget.product.totalPrice.toStringAsFixed(2)}"),
                ),
                StreamBuilder<List<String>>(
                    stream: context.select((PeopleService s) => s.peopleStream),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      var people = snapshot.data;
                      return AnimatedCrossFade(
                        duration: Duration(milliseconds: 300),
                        crossFadeState: editing
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        alignment: Alignment.topLeft,
                        firstChild: Wrap(
                          direction: Axis.horizontal,
                          children: [
                            for (int i = 0; i < people.length; i++) ...[
                              buildPersonCheckbox(people[i]),
                              SizedBox(
                                width: 8,
                              )
                            ]
                          ],
                        ),
                        secondChild: Container(),
                      );
                    }),
              ],
            ),
          ),
          IconButton(
            icon: Icon(editing ? Icons.check : Icons.edit),
            onPressed: () => setState(
              () => editing = !editing,
            ),
          )
        ],
      ),
    );
  }

  Widget buildPersonCheckbox(String name) {
    return ChoiceChip(
      elevation: widget.checkedPeople.contains(name) ? 8 : 0,
      label: Text(name),
      backgroundColor: Colors.primaries[
              context.read<PeopleService>().people.indexOf(name) *
                  5 %
                  Colors.primaries.length]
          .withOpacity(0.2),
      selectedColor: Colors.primaries[
              context.read<PeopleService>().people.indexOf(name) *
                  5 %
                  Colors.primaries.length]
          .withOpacity(0.8),
      labelStyle: TextStyle(color: Colors.black),
      selected: widget.checkedPeople.contains(name),
      onSelected: (value) {
        setState(() {
          if (value) {
            widget.checkedPeople.add(name);
          } else {
            widget.checkedPeople.remove(name);
          }
        });
      },
    );
  }
}
