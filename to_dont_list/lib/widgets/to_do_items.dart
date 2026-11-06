import 'package:flutter/material.dart';
import 'package:to_dont_list/objects/item.dart';

typedef GroceryListChangedCallback = Function(GroceryItem item, bool completed);
typedef GroceryListRemovedCallback = Function(GroceryItem item);

class GroceryListItem extends StatefulWidget {
  GroceryListItem(
      {required this.item,
      required this.completed,
      required this.onListChanged,
      required this.onDeleteItem})
      : super(key: ObjectKey(item));

  final GroceryItem item;
  final bool completed;

  final GroceryListChangedCallback onListChanged;
  final GroceryListRemovedCallback onDeleteItem;

  Color _getColor(BuildContext context) {
    // The theme depends on the BuildContext because different
    // parts of the tree can have different themes.
    // The BuildContext indicates where the build is
    // taking place and therefore which theme to use.

    return completed //
        ? Colors.black54
        : Colors.lightBlue;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!completed) return null;

    return const TextStyle(
      color: Colors.black,
      decoration: TextDecoration.lineThrough,
    );
  }
  @override
  State<GroceryListItem> createState() => _GroceryListItemState();
  
}
class _GroceryListItemState extends State<GroceryListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        widget.onListChanged(widget.item, widget.completed);
      },
      /*onLongPress: widget.completed
          ? () {
              widget.onDeleteItem(widget.item);
            }
          : null,*/
      leading: CircleAvatar(
        backgroundColor: widget._getColor(context),
        child: Text(widget.item.quantity.toString()),
      ),
      title: Text(
        widget.item.name,
        style: widget._getTextStyle(context),
      ),
      //OverflowBar implementation from https://api.flutter.dev/flutter/widgets/OverflowBar-class.html
      trailing: OverflowBar(
        spacing: 8,
        overflowAlignment: OverflowBarAlignment.end,
        children: <Widget>[
          ElevatedButton(key: const Key("Increment"), onPressed: (){
            setState((){widget.item.increment();});
            },child: const Text('+'),),
          ElevatedButton(key: const Key("Decrement"), onPressed: (){
            setState((){widget.item.decrement();});
            //if item quantity reaches 0 it is deleted
            if (widget.item.quantity == 0){
                setState((){widget.onDeleteItem(widget.item);});
            }
            }, child: const Text('-')),
          //delete item buttom
          ElevatedButton(key: const Key("Remove"), onPressed: (){
            setState((){widget.onDeleteItem(widget.item);});
            },child: const Text('Remove'),),
        ],
      ),
    );
  }
}