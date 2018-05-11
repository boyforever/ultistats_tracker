import 'dart:async' show Future;
import 'dart:io';
import 'ioclass.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'statsscreen.dart';

void main() => runApp(new MyApp());
List<Tournament> _tournaments = new List<Tournament>();
//List<Game> _games = new List<Game>();
//List<GameData> _gameData = new List<GameData>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'UltiStats Tracker',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new TournamentsScreen(),
    );
  }
}

class TournamentsScreen extends StatefulWidget{
  @override
  TournamentsScreenState createState() => new TournamentsScreenState();
}
class TournamentsScreenState extends State<TournamentsScreen>{
  //List<ListTile> _gamesList = new List<ListTile>();
  @override
  void initState() {
    super.initState();
    loadTournaments().then((List<Tournament> t){
      setState((){
        _tournaments = t;
        for(var _t in _tournaments){
          loadGames(_t.id).then((List<Game> g){
            _t.games = g;           
          });
        }
        // for(var _g in _games){
        //   loadGameData(_g.id).then((GameData value){
        //     _g.data = value;
        //   });
        // }
      });
    });
  }
  void nextToStatsScreen(Tournament t, int index){
    //if(g.data == null) g.data = new GameData(g.id,0,0,0,0,0,0);
    if(t.games[index] != null){
      Navigator.push(context, new MaterialPageRoute(builder: (context) => new StatsScreen(tournament: t, index: index,)));
    }
  }
  List<ListTile> getListOfGames(Tournament t){
    List<ListTile> results = new List<ListTile>();
    for(int i=0; i<t.games.length; i++){
      if(t.games[i] != null){
        results.add(new ListTile(title: new Text(t.games[i].home + " VS. " + t.games[i].guest , style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.normal, color: Colors.black),),onTap: (){ 
        nextToStatsScreen(t, i);
        },));
      }
    }
    return results;
  }
  List<Widget> getListOfTournaments(){    
    List<Widget> results = new List<Widget>();    
    if (_tournaments == null) {
      results.add(new Text("Sorry, something went wrong on our end."));
      return results;
    }
    for (var item in _tournaments) {
      results.add(new ExpansionTile(
        initiallyExpanded: true,
        leading: new IconButton(icon: new Icon(Icons.add_circle, color: Colors.blueAccent,),onPressed: (){ 
          showDialog(context: context, builder: (context)=>inputGameDialog(item) );
          }),
        title: new Text(item.title + " - " + item.date, style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),),
        children: getListOfGames(item)
        )
      );
    }
    return results;
  }
  Future<File> saveGame(Tournament t, String guest) async {
    setState(() { 
      t.games.add(new Game("g" + new DateTime.now().millisecondsSinceEpoch.toString(), t.id, guest, 0,0,0,0,0,0));
      //_.add(new Game("g" + new DateTime.now().millisecondsSinceEpoch.toString(), tournamentid, guest, 0,0,0,0,0,0)); 
    });
    return rewriteGames(t);
  }
  Widget inputGameDialog(Tournament t){
    final _titleController = new TextEditingController();
    bool _isButtonDisabled = true;
    return new SimpleDialog(
      contentPadding: new EdgeInsets.all(20.0),
      children: <Widget>[
      new TextFormField(
        validator: (value){ _isButtonDisabled = value.isEmpty;},
        autovalidate: true,
        controller: _titleController,
        decoration: const InputDecoration( labelText: 'Enter Opponent Team Name', ),
        style: Theme.of(context).textTheme.subhead,
      ),
      new FlatButton(disabledColor: Colors.grey, padding: new EdgeInsets.only(top:20.0), onPressed: (){ if(!_isButtonDisabled) { 
        Navigator.pop(context, "SAVE"); 
        saveGame(t,_titleController.text);}}, child: new Icon(Icons.save, size: 48.0,),),
      ]            
    );
  }
  Future<File> saveTournament(String title, String date) async {    
    setState(() { _tournaments.add(new Tournament('t' + new DateTime.now().millisecondsSinceEpoch.toString(), title, date)); });
    return rewriteTournaments(_tournaments);
  }
  Widget inputTournamentDialog(){
    final _titleController = new TextEditingController();
    bool _isButtonDisabled = true;
    DateTime _fromDate = new DateTime.now();
    return new SimpleDialog(
      contentPadding: new EdgeInsets.all(20.0),
      children: <Widget>[
        new TextFormField(
          validator: (value){ _isButtonDisabled = value.isEmpty;},
          autofocus: true,
          autovalidate: true,
          controller: _titleController,
          decoration: const InputDecoration( labelText: 'Enter Tournament name',),
          style: Theme.of(context).textTheme.subhead,
        ),
        new _DateTimePicker(
          labelText: 'Date',
          selectedDate: _fromDate,          
          selectDate: (DateTime date) {
            setState(() {
              _fromDate = date; // "${date.year.toString()}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
            });
          },
        ),
        new FlatButton(padding: new EdgeInsets.only(top:20.0), onPressed: (){if(!_isButtonDisabled) {
          Navigator.pop(context, "SAVE"); 
          saveTournament(_titleController.text, new DateFormat.yMMMd().format(_fromDate) );}}, child: new Icon(Icons.save, size: 48.0,),),
      ]
    );
  }
  @override
  Widget build(BuildContext context) {
    return 
       new Scaffold(
        appBar: new AppBar(title: new Text("UltiStats Tracker"), leading: new Image.asset('assets/ultimate.png'),),
        body: new ListView(
          padding: const EdgeInsets.all(20.0),
          children: getListOfTournaments(),
        ),
        floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add,),
          backgroundColor: Colors.lightBlueAccent,
          onPressed: (){
            showDialog(context: context, builder: (context)=>inputTournamentDialog() );
          }
        )
      );  
  } 
}
class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectedTime,
    this.selectDate,
    this.selectTime
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: new DateTime(2015, 8),
      lastDate: new DateTime(2101)
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDropdown(
            labelText: labelText,
            valueText: new DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () { _selectDate(context); },
          ),
        ),
        // const SizedBox(width: 12.0),
      ],
    );
  }
}

