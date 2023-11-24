import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resonance_chatroom/constants/constants.dart';

class Activity {
  final String ownerid;
  final String activityid;
  final String activityname;
  final String activityinfo;
  final String enddate;

  const Activity({
    required this.ownerid,
    required this.activityid,
    required this.activityname,
    required this.activityinfo,
    required this.enddate,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.ownerid: ownerid,
      FirestoreConstants.activityid: activityid,
      FirestoreConstants.activityname: activityname,
      FirestoreConstants.activityinfo: activityinfo,
      FirestoreConstants.enddate: enddate,
    };
  }

  factory Activity.fromDocument(DocumentSnapshot doc) {
    String ownerid = doc.get(FirestoreConstants.ownerid);
    String activityid = doc.get(FirestoreConstants.activityid);
    String activityname = doc.get(FirestoreConstants.activityname);
    String activityinfo = doc.get(FirestoreConstants.activityinfo);
    String enddate = doc.get(FirestoreConstants.enddate);
    return Activity(
      ownerid: ownerid,
      activityid: activityid,
      activityname: activityname,
      activityinfo: activityinfo,
      enddate: enddate,
    );
  }
}