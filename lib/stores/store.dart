import 'dart:collection';
import 'package:newspector_flutter/models/model.dart';

class Store<E extends Model> {
  HashMap<String, E> _items;

  Store() {
    _items = HashMap<String, E>();
  }

  E getItem(String id) {
    return _items[id];
  }

  bool hasItem(String id) {
    return _items.containsKey(id);
  }

  E updateOrAddItem(E item) {
    var id = item.id;
    _items[id] = item;
    return item;
  }
}
