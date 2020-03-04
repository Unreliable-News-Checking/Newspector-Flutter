import 'package:newspector_flutter/models/user.dart';
import 'package:flutter/material.dart';

class CreateNewBetPage extends StatefulWidget {
  @override
  _CreateNewBetPageState createState() => _CreateNewBetPageState();
}

class _CreateNewBetPageState extends State<CreateNewBetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: "Name",
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Wager",
                hintText: "amount",
              ),
            ),
            AddFriendsButton(),
          ],
        ),
      ),
    );
  }
}

class AddFriendsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text("Add Friends"),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          builder: (context) => AddFriendsSheet(),
        );
      },
    );
  }
}

class AddFriendsSheet extends StatefulWidget {
  @override
  _AddFriendsSheetState createState() => _AddFriendsSheetState();
}

class _AddFriendsSheetState extends State<AddFriendsSheet> {
  var mockUser = User();

  @override
  void initState() {
    super.initState();
    mockUser.notificationToken = "abshd";
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.5,
      initialChildSize: 0.75,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.blueGrey,
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: <Widget>[
                    SearchBar(),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                    AddFriendCard(mockUser),
                  ],
                ),
              ),
              RaisedButton(
                child: Text("Add"),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          decoration: InputDecoration.collapsed(
            hintText: 'Search',
          ),
        ),
      ),
    );
  }
}

class AddFriendCard extends StatefulWidget {
  final User user;
  AddFriendCard(this.user);

  @override
  _AddFriendCardState createState() => _AddFriendCardState();
}

class _AddFriendCardState extends State<AddFriendCard> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        child: Row(
          children: <Widget>[
            Text(widget.user.notificationToken),
            Checkbox(
              value: false,
              onChanged: (value) {
                
              },
            )
          ],
        ),
      ),
    );
  }
}
