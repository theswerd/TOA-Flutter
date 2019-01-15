import 'package:flutter/material.dart';
import 'package:toa_flutter/providers/StaticData.dart';
import 'package:toa_flutter/Sort.dart';
import 'package:toa_flutter/models/EventParticipant.dart';
import 'package:toa_flutter/models/TeamParticipant.dart';
import 'package:toa_flutter/models/Ranking.dart';
import 'package:toa_flutter/models/Match.dart';
import 'package:toa_flutter/providers/ApiV3.dart';
import 'package:toa_flutter/ui/widgets/EventListItem.dart';
import 'package:toa_flutter/ui/widgets/MatchListItem.dart';
import 'package:toa_flutter/ui/widgets/NoDataWidget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TeamResults extends StatelessWidget {

  TeamResults(this.teamKey);
  final String teamKey;

  List<TeamParticipant> data;

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return FutureBuilder<List<TeamParticipant>>(
        future: getTeamParticipants(teamKey),
        initialData: null,
        builder: (BuildContext context, AsyncSnapshot<List<TeamParticipant>> teamParticipants) {
          if (teamParticipants.data != null) {
            data = teamParticipants.data;
          }
          return bulidPage();
        }
      );
    } else {
      return bulidPage();
    }
  }

  Widget bulidPage() {
    if (data != null) {
      if (data.length > 0) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return bulidItem(data[index]);
          }
        );
      } else {
        return NoDataWidget(MdiIcons.calendarOutline, "No events found");
      }
    } else {
      return Center(
        child: CircularProgressIndicator()
      );
    }
  }

  Widget bulidItem(TeamParticipant teamParticipant) {
    List<Widget> card = [];
    List<Match> matches = teamParticipant.matches;

    // Title
    card.add(EventListItem(teamParticipant.event));
    card.add(Divider(height: 0));

    // Ranking
    if (teamParticipant.ranking != null && !teamParticipant.ranking.rank.isNaN) {
      card.add(ListTile(
        title: Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'Qual Rank '),
              TextSpan(text: '#${teamParticipant.ranking.rank} ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'with a record of '),
              TextSpan(text: '${teamParticipant.ranking.wins}-${teamParticipant.ranking.losses}-${teamParticipant.ranking.ties}', style: TextStyle(fontWeight: FontWeight.bold)),
            ]
          )
        )
      ));
    }

    if (matches.length > 0) {
      for (int i = 0; i < matches.length; i++) {
        card.add(MatchListItem(matches[i]));
      }
    } else {
      card.add(Padding(
        padding: EdgeInsets.all(12),
        child: NoDataWidget(MdiIcons.gamepadVariant, "No matches found", mini: true)
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: card
        )
      )
    );
  }

  Future<List<TeamParticipant>> getTeamParticipants(String teamKey) async {
    List<TeamParticipant> teamParticipants = [];

    // Get all the team's rankings
    List<Ranking> allRankings = await ApiV3().getTeamResults(teamKey, StaticData().sessonKey);

    await ApiV3().getTeamEvents(teamKey, StaticData().sessonKey).then((events) async {
      events.sort(Sort().eventParticipantSorter);

      for (int i = 0; i < events.length; i++) {
        EventParticipant eventParticipant = events[i];
        TeamParticipant teamParticipant = TeamParticipant();

        // Get event detail
        teamParticipant.event = await ApiV3().getEvent(eventParticipant.eventKey);

        // Get team matches
        List<Match> teamMatches = [];
        await ApiV3().getEventMatches(eventParticipant.eventKey).then((matches) {
          for (int i = 0; i < matches.length; i++) {
            Match match = matches[i];
            for (int i = 0; i < match.participants.length; i++) {
              if (match.participants[i].teamKey == teamKey) {
                teamMatches.add(match);
                break;
              }
            }
          }
        });
        teamMatches.sort(Sort().matchSorter);
        teamParticipant.matches = teamMatches;

        // Find the ranking in the event
        for (int i = 0; i < allRankings.length; i++) {
          Ranking ranking = allRankings[i];
          if (ranking.eventKey == eventParticipant.eventKey) {
            teamParticipant.ranking = ranking;
            break;
          }
        }

        teamParticipants.add(teamParticipant);
      }
    });

    return teamParticipants;
  }
}