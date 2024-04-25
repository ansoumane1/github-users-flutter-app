import "dart:convert";

import "package:flutter/material.dart";
import "package:githubuser_mobile_app/repositories/users.page.dart";
import "package:http/http.dart" as http;

class UserPage extends StatefulWidget {
  const UserPage({super.key});
  @override
  UserPageState createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  bool notVisible = false;
  String query = '';
  final TextEditingController queryTextEditingController =
      TextEditingController();
  dynamic data;
  int currentPage = 0;
  int totalPages = 0;
  int pageSize = 20;
  List<dynamic> items = [];

  ScrollController scrollController = ScrollController();

  void _search(String query) {
    String url =
        "https://api.github.com/search/users?q=$query&per_page=$pageSize&page=$currentPage";
    http.get(Uri.parse(url)).then((response) {
      setState(() {
        data = json.decode(response.body);
        items.addAll(data['items']);
        if (data['total_count'] % pageSize == 0) {
          totalPages = data['total_count'] ~/ pageSize;
        } else {
          totalPages = (data["total_count"] / pageSize).floor() + 1;
        }
      });
    }).catchError((err) {
      print(err);
    });
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to the Scroll Controller that checks when we're at the end of the list and need to load more.
    scrollController.addListener(() {
      double maxScroll = scrollController.position.maxScrollExtent;
      double currentScroll = scrollController.position.pixels;
      if (currentScroll == maxScroll) {
        setState(() {
          if (currentPage < totalPages) {
            ++currentPage;
            _search(query);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Users =>$query =>$currentPage / $totalPages"),
        ),
        body: Center(
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      obscureText: notVisible,
                      onChanged: (value) {
                        setState(() => query = value);
                      },
                      controller: queryTextEditingController,
                      decoration: InputDecoration(
                        //icon: const Icon(Icons.logout),
                        suffixIcon: IconButton(
                          icon: Icon(notVisible == true
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() => notVisible = !notVisible);
                          },
                        ),
                        contentPadding: const EdgeInsets.only(left: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: const BorderSide(
                              width: 1, color: Colors.deepOrange),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.deepOrange),
                  onPressed: () {
                    setState(() {
                      items = [];
                      currentPage = 0;
                      query = queryTextEditingController.text;
                      if (query.isNotEmpty) {
                        _search(query);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a search term')));
                      }
                    });
                  },
                )
              ],
            ),
            Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        const Divider(height: 2, color: Colors.deepOrange),
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GitRepositoriesPage(
                                          login: items[index]['login'],
                                          avatarurl: items[index]['avatar_url'],
                                        )));
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(items[index]['avatar_url']),
                                  radius: 20,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text("${items[index]['login']}"),
                              ]),
                              CircleAvatar(
                                child: Text("${items[index]['score']}"),
                              )
                            ],
                          ));
                    }))
          ]),
        ));
  }
}
