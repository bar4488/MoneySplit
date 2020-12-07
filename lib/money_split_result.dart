import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class MoneySplitResult extends StatelessWidget {
  final Map<String, double> moneySplit;

  MoneySplitResult(this.moneySplit);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 16,
        ),
        Text(
          "Total Payment Result:",
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox(height: 8),
        Divider(
          thickness: 1,
          indent: 16,
          endIndent: 16,
          height: 1,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (MapEntry<String, double> entry in moneySplit.entries)
                  buildPersonItem(entry.key, entry.value),
                Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  title: Text(
                    "Total:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    moneySplit.values
                        .reduce((v1, v2) => v1 + v2)
                        .toStringAsFixed(2),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                RaisedButton(
                  onPressed: () async {
                    await FlutterShare.share(
                        title: "Money split result",
                        text: jsonEncode(moneySplit));
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text("Share!"),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildPersonItem(String name, double money) {
    return ListTile(
      title: Text(name),
      trailing: Text(money.toStringAsFixed(2)),
    );
  }
}
