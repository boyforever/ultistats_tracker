import 'dart:async' show Future;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Tournament {
  String id, title, date;
  Tournament([this.id, this.title, this.date]);
}
class Game {
  String id, tournamentid, home="Bayview", guest;  
  Game([this.id, this.tournamentid, this.guest]);
}
class GameData {
  String gameid;
  int homeScore, guestScore, goals, assists, blocks, turnovers;
  GameData([this.gameid, this.homeScore, this.guestScore, this.goals, this.assists, this.blocks, this.turnovers]);
}

// class ContentStorage { 
  // Tournament file
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return new File('$path/$filename.txt');
  }
  Future<List<Tournament>> loadTournaments() async {
    List<Tournament> _ts = new List<Tournament>();
    try {
      final file = await _localFile("tournaments");
      String contents = await file.readAsString();
      List<String> list = contents.split("|");
      for(var i = 0; i < list.length; i=i+3) _ts.add(new Tournament(list[i], list[i+1], list[i+2]));
    } catch (e) {
    } 
    return _ts;
  }
  Future<File> rewriteTournaments(List<Tournament> ts) async {
    try {
      final file = await _localFile("tournaments");
      String _x = "";
      for(int i=0; i<ts.length; i++) _x = _x + "|" +  ts[i].id + "|" + ts[i].title + "|" + ts[i].date;
      return file.writeAsString(_x.substring(1), mode: FileMode.WRITE_ONLY);
    } catch(er) { return null;}
  }
  // Game file
  Future<List<Game>> loadGames(String tournamentid) async {
    List<Game> _ts = new List<Game>();
    try {
      final file = await _localFile(tournamentid);
      String contents = await file.readAsString();
      List<String> list = contents.split("|");
      for(var i = 0; i < list.length; i=i+3) _ts.add(new Game(list[i], list[i+1], list[i+2]));
    } catch (e) { } 
    return _ts;
  }
  Future<File> rewriteGames(String tournamentid, List<Game> ts) async {
    try {
      final file = await _localFile(tournamentid);
      String _x = "";
      for(int i=0; i<ts.length; i++) _x = _x + "|" +  ts[i].id + "|" + ts[i].tournamentid + "|" + ts[i].guest;
      return file.writeAsString(_x.substring(1), mode: FileMode.WRITE_ONLY);
    } catch(er) { return null;}
  }
  // game data
  Future<GameData> loadGameData(String gameid) async {
    try{
      final file = await _localFile(gameid);
      String contents = await file.readAsString();
      List<String> list = contents.split("|");
      return new GameData(list[0], int.parse(list[1]), int.parse(list[2]), int.parse(list[3]), int.parse(list[4]), int.parse(list[5]), int.parse(list[6]) );
    } catch(e) { return new GameData(gameid, 0,0,0,0,0,0);}
  }
  Future<File> rewriteGameData(GameData g) async {
    try{
      final file = await _localFile(g.gameid);
      String _x = g.gameid + "|" + g.homeScore.toString() + "|" + g.guestScore.toString() + "|" + g.goals.toString() + "|" + g.assists.toString() + "|" + g.blocks.toString() + "|" + g.turnovers.toString();
      return file.writeAsString(_x, mode: FileMode.WRITE_ONLY);
    }catch(er) { return null;}
  }
// }
