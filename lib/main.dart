import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDocontroller = TextEditingController();
  // ignore: unused_field
  var _lastRemove = {};
  // ignore: unused_field
  var _lastRemovePosition = 0;

  var _lista = [];

  void addlist() {
    setState(() {
      _lista.add({
        "title": _toDocontroller.text,
        "ok": false,
      });
      //salvar
      _saveData();
      _toDocontroller.text = "";
    });
  }

  Widget _buildItem(context, index) {
    var item = _lista[index];
    print(_lista);
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 10.0),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: CheckboxListTile(
        title: Text(item["title"]),
        value: item["ok"],
        secondary: CircleAvatar(
          child: Icon(item["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (ok) {
          setState(() {
            item["ok"] = ok;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          //ultimo removido
          _lastRemove = Map.from(item);
          _lastRemovePosition = index;
          //remover da lista
          _lista.removeAt(index);
          //salvar
          _saveData();

          // ignore: unused_local_variable
          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemove["title"]}\" removida!"),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _lista.insert(_lastRemovePosition, _lastRemove);
                    _saveData();
                  });
                }),
          );

          //limpar pilhar
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          //mostrar o Snakbar
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<Null> _refresh() async {
    setState(() {
      _lista.sort((a, b) {
        return a['title'].toLowerCase().compareTo(b['title'].toLowerCase());
      });
      //ordenar lista
      _lista.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      //salvar
      _saveData();
    });

    //item = item.reversed.toList();
    // ignore: unused_local_variable
    //var orden = "A-Z";
  }

  // ignore: unused_element
  Future<File> _saveData() async {
    String data = json.encode(_lista);
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/data.json");
    return file.writeAsString(data);
  }

  // ignore: unused_element
  Future<String> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/data.json");

      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData().then((data) {
      setState(() {
        _lista = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Lista de tarefas"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                  controller: _toDocontroller,
                )),
                TextButton(
                  child: Text(
                    "ADD",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blueAccent)),
                  onPressed: addlist,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _lista.length,
                  itemBuilder: _buildItem),
            ),
          ),
        ],
      ),
    );
  }
}
