import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class GitRepositoriesPage extends StatefulWidget {
  final String login;
  final String avatarurl;

  const GitRepositoriesPage(
      {super.key, required this.login, required this.avatarurl});

  @override
  GitRepositoriesPageState createState() => GitRepositoriesPageState();
}

class GitRepositoriesPageState extends State<GitRepositoriesPage> {
  dynamic dataRepositories;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadGitRepositories();
  }

  void _loadGitRepositories() {
    String url = 'https://api.github.com/users/${widget.login}/repos';
    http.get(Uri.parse(url)).then((response) {
      if (response.statusCode == 200) {
        setState(() {
          dataRepositories = json.decode(response.body);
        });
      }
    }).catchError((error) {
      print('Failed to load git repositories for ${widget.login}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Repositories ${widget.login}"), actions: [
        CircleAvatar(
          backgroundImage: NetworkImage(widget.avatarurl),
        )
      ]),
      body: Center(
        child: ListView.separated(
          itemBuilder: (context, index) =>
              ListTile(title: Text("${dataRepositories[index]['name']}")),
          separatorBuilder: (context, index) =>
              const Divider(height: 2, color: Colors.deepOrange),
          itemCount: dataRepositories == null ? 0 : dataRepositories.length,
        ),
      ),
    );
  }
}
