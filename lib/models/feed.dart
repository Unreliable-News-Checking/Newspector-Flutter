class Feed<E> {
  List<E> items;

  Feed() {
    items = List<E>();
  }

  int getItemCount() {
    return items.length;
  }

  E getItem(int index) {
    return items[index];
  }

  E getLastItem() {
    return items.last;
  }
}