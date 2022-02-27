import 'package:flutter/material.dart';
import '../data/sp_helper.dart';
import '../data/session.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final List<Session> sessions = [];
  final TextEditingController txtDescription = TextEditingController();
  final TextEditingController txtDuration = TextEditingController();
  final SpHelper spHelper = SpHelper();

  @override
  void initState() {
    spHelper.init().then((value) {
      updateScreen();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Training Sessions'),
      ),
      body: ListView(children: getContent()),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            showSessionDialog(context);
          }),
    );
  }

  Future<dynamic> showSessionDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Insert Trainig Session'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: txtDescription,
                  decoration: const InputDecoration(hintText: 'Description'),
                ),
                TextField(
                  controller: txtDuration,
                  decoration: const InputDecoration(hintText: 'Duration'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                  txtDescription.text = '';
                  txtDuration.text = '';
                }),
            ElevatedButton(child: const Text('Save'), onPressed: saveSession),
          ],
        );
      },
    );
  }

  Future saveSession() async {
    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month}-${now.day}';

    int id = spHelper.getCounter() + 1;

    Session session = Session(
        id, today, txtDescription.text, int.tryParse(txtDuration.text) ?? 0);

    spHelper.writeSession(session).then((_) {
      updateScreen();
      spHelper.setCounter();
    });
    txtDescription.text = '';
    txtDuration.text = '';
    Navigator.pop(context);
  }

  List<Widget> getContent() {
    List<Widget> tiles = [];
    sessions.forEach((session) {
      tiles.add(Dismissible(
        key: UniqueKey(),
        onDismissed: (_) {
          spHelper.deleteSession(session.id).then((value) => updateScreen());
        },
        child: ListTile(
          title: Text(session.description),
          subtitle: Text('${session.date} - duration: ${session.duration} min'),
        ),
      ));
    });
    return tiles;
  }

  void updateScreen() {
    spHelper.getSessions();
    setState(() {});
  }
}
