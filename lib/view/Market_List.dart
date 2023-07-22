import 'package:auto_bitcoin/models/res_martket_code.dart';
import 'package:flutter/material.dart';

class MarketList extends StatefulWidget {
  const MarketList(this.list, this.onMarketCode, {super.key});

  final void Function(String) onMarketCode;

  final List<ItemMarketCode>? list;

  @override
  State<MarketList> createState() => _MarketListState();
}

class _MarketListState extends State<MarketList> {
  String dropdownValue = '';
  List<String> datas = [];

  @override
  void initState() {
    super.initState();
    if (widget.list != null) {
      dropdownValue = widget.list!.first.koreanName!;

      for (var element in widget.list!) {
        if (element.market!.contains('KRW')) {
          datas.add(element.koreanName!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.white),
      dropdownColor: const Color.fromARGB(255, 20, 20, 28),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          int index = widget.list!.indexWhere((element) =>
              element.koreanName == dropdownValue &&
              element.market!.contains('KRW'));
          widget.onMarketCode(widget.list![index].market!);
        });
      },
      items: datas.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
