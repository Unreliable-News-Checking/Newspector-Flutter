class Feed<E> {
  List<E> _items;

  Feed() {
    _items = List<E>();
  }

  Feed.fromItems(List<E> items) {
    this._items = items;
  }

  int getItemCount() {
    return _items.length;
  }

  E getItem(int index) {
    return _items[index];
  }

  E getLastItem() {
    return _items.last;
  }

  void addAdditionalItems(List<E> additionalItems) {
    _items.addAll(additionalItems);
  }

  void clearItems() {
    _items.clear();
  }
}
