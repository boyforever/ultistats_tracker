import 'dart:async' show Future;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Tournament {
  String id, title, date;
  int goals=0, assists=0, blocks=0, turnovers=0;
  List<Game> games;
  Tournament([this.id, this.title, this.date, this.games, this.goals, this.assists, this.blocks, this.turnovers]);
}
class Game {
  String id, tournamentid, home="Bayview", guest;  
  int homeScore=0, guestScore=0, goals=0, assists=0, blocks=0, turnovers=0;
  //GameData data;
  Game([this.id, this.tournamentid, this.guest, this.homeScore, this.guestScore, this.goals, this.assists, this.blocks, this.turnovers]);
}
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
      for(var i = 0; i < list.length; i=i+3) _ts.add(new Tournament(list[i], list[i+1], list[i+2],new List<Game>(), 0,0,0,0));
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
      for(var i = 0; i < list.length; i=i+9) _ts.add(new Game(list[i], list[i+1], list[i+2], int.parse(list[i+3]), int.parse(list[i+4]), int.parse(list[i+5]), int.parse(list[i+6]), int.parse(list[i+7]), int.parse(list[i+8])));
    } catch (e) { } 
    return _ts;
  }
  Future<File> rewriteGames(Tournament t) async {
    try {
      final file = await _localFile(t.id);
      String _x = "";
      for(int i=0; i<t.games.length; i++) _x = _x + "|" +  t.games[i].id + "|" + t.games[i].tournamentid + "|" + t.games[i].guest + "|" + t.games[i].homeScore.toString() + "|" + t.games[i].guestScore.toString() + "|" + t.games[i].goals.toString() + "|" + t.games[i].assists.toString() + "|" + t.games[i].blocks.toString() + "|" + t.games[i].turnovers.toString();
      return file.writeAsString(_x.substring(1), mode: FileMode.WRITE_ONLY);
    } catch(er) { return null;}
  }