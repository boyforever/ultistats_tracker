import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ioclass.dart';

final double _kPickerSheetHeight = 216.0;
final double _kPickerItemHeight = 36.0;
final nums = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30];
GameData _game = new GameData("",0,0,0,0,0,0);

class StatsScreen extends StatefulWidget {
  //final ContentStorage storage;
  final Game game;
  StatsScreen({Key key, @required  this.game}) : super(key: key);
  @override
  StatsScreenState createState() => new StatsScreenState();
}

class StatsScreenState extends State<StatsScreen>{
  @override
  void initState() {
    super.initState();
    loadGameData(widget.game.id).then((GameData value){
      setState((){
        _game = value;
      });
    });
  }
  Widget _singlePicker(FixedExtentScrollController scrollController, int _controllerId, String _label, Color _labelColor){    
    return 
    new Column(children: <Widget>[
      new Container(      
        height: _kPickerSheetHeight,
        padding: new EdgeInsets.only(bottom: 20.0),
        child: new DefaultTextStyle(
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 22.0,
          ),
          child: new GestureDetector(
            // Blocks taps from propagating to the modal sheet and popping.
            onTap: () {},
            child: new SafeArea(
              child: new CupertinoPicker(
                scrollController: scrollController,
                itemExtent: _kPickerItemHeight,
                backgroundColor: CupertinoColors.lightBackgroundGray,              
                onSelectedItemChanged: (int index) {
                  setState(() {
                    switch(_controllerId){
                      case 1: _game.homeScore = index; break;
                      case 2: _game.guestScore = index; break;
                      case 3: _game.goals = index; break;
                      case 4: _game.assists = index; break;
                      case 5: _game.blocks = index; break;
                      case 6: _game.turnovers = index; break;
                    }
                  });
                  // Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("You pressed $index"), action: new SnackBarAction(label: "Click to Save.", onPressed: (){rewriteGameData(_game);},),));
                },
                children: new List<Widget>.generate(nums.length, (int index) {
                  return new Center(child:
                    new Text(nums[index].toString()),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      new Text(_label, textAlign: TextAlign.center, style: new TextStyle(color: _labelColor, fontWeight: FontWeight.bold, fontSize: 24.0),)
      ]);

    }

    Widget _buildScorePicker() {
      final FixedExtentScrollController scrollController1 = new FixedExtentScrollController(initialItem: _game.homeScore);
      final FixedExtentScrollController scrollController2 = new FixedExtentScrollController(initialItem: _game.guestScore);
      return new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: _singlePicker(scrollController1, 1, "HOME", Colors.lightBlueAccent),
              ),
              new Text(" VS ", textAlign: TextAlign.center, style: new TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 24.0),),
              new Expanded(
                child: _singlePicker(scrollController2, 2, "GUEST",  Colors.amber),
              )
            ],
          ),
        ],
    );
  }
  // Blocks, Turnovers
  Widget _buildStatsPicker() {
    final FixedExtentScrollController scrollController3 = new FixedExtentScrollController(initialItem: _game.goals);
    final FixedExtentScrollController scrollController4 = new FixedExtentScrollController(initialItem: _game.assists);
    final FixedExtentScrollController scrollController5 = new FixedExtentScrollController(initialItem: _game.blocks);
    final FixedExtentScrollController scrollController6 = new FixedExtentScrollController(initialItem: _game.turnovers);
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Expanded(
              child: _singlePicker(scrollController3, 3, "GOALS", Colors.lightBlueAccent),
            ),
            new Expanded(
              child: _singlePicker(scrollController4, 4, "ASSISTS", Colors.lightBlueAccent),
            )
          ],
        ),  
        new Row(
          children: <Widget>[
            new Expanded(
              child: _singlePicker(scrollController5, 5, "BLOCKS", Colors.lightBlueAccent),
            ),
            new Expanded(
              child: _singlePicker(scrollController6, 6, "TURNOVERS", Colors.lightBlueAccent),
            )
          ],
        ),     
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: new AppBar(
            leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: (){Navigator.pop(context);},),            
            title: new Text(widget.game.home + " VS. " + widget.game.guest),
            bottom: new TabBar(
              tabs: [
              new Tab(icon: new Icon(Icons.games),),
              new Tab(icon: new Icon(Icons.trending_up),),
              ]
            ),
          ),
          body:  new TabBarView(
                children: <Widget>[
                  _buildScorePicker(),
                  _buildStatsPicker(),
                ],                
          ),              
          floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(Icons.check,),
            backgroundColor: Colors.lightBlueAccent,
            onPressed: (){ rewriteGameData(_game);}
          )            
        )
      ),
    );
  }
}