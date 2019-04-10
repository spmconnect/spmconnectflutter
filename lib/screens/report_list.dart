import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:spmconnectapp/screens/reportdetailtabs.dart';
import 'package:flushbar/flushbar.dart';

class ReportList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportList();
  }
}

class _ReportList extends State<ReportList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Report> reportlist;
  List<Report> reportmapid;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (reportlist == null) {
      reportlist = List<Report>();
      updateListView();
    }

    if (reportmapid == null) {
      reportmapid = List<Report>();
      getReportmapId();
    }

    return WillPopScope(
      onWillPop: () {
        movetolastscreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('SPM Connect Service Reports'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              movetolastscreen();
            },
          ),
        ),
        body: getReportListView(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            debugPrint('FAB clicked');
            getReportmapId();
            int mapid = 0;
            if (count == 0) {
              mapid = 1001;
            } else {
              mapid = reportmapid[0].reportmapid + 1;
            }
            navigateToDetail(Report('', '', '', '', '', '', '', '', mapid),
                'Add New Report');
          },
          tooltip: 'Create New Report',
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  ListView getReportListView() {
    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 10.0,
          child: ListTile(
            title: Text(
              'Report No - ' +
                  this.reportlist[position].reportmapid.toString() +
                  ' ( ' +
                  this.reportlist[position].date +
                  ' )',
              style: titleStyle,
            ),
            subtitle: Text(
              'Project - ' +
                  this.reportlist[position].projectno +
                  " ( " +
                  this.reportlist[position].customer +
                  ' )',
              style: titleStyle,
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: () {
                //_delete(context, reportlist[position]);
                _neverSatisfied(position);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.reportlist[position], 'Edit Report');
            },
          ),
        );
      },
    );
  }

  void movetolastscreen() {
    Navigator.pop(context, true);
  }

  void _delete(BuildContext context, Report report) async {
    int result = await databaseHelper.deleteReport(report.id);
    if (result != 0) {
      debugPrint('deleted report');
      //_showSnackBar(context, 'Report Deleted Successfully');
      updateListView();
      reportmapid.clear();
      getReportmapId();
    }
    int result2 = await databaseHelper.deleteAllTasks(report.reportmapid);
    if (result2 != 0) {
      debugPrint('deleted all tasks');
      //_showSnackBar(context, 'Report Deleted Successfully');
    }
  }

  // void _showSnackBar(BuildContext context, String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  void navigateToDetail(Report report, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ReportDetTab(report, title);
    }));
    if (result == true) {
      updateListView();
    }
    reportmapid.clear();
    getReportmapId();
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Report>> reportListFuture = databaseHelper.getReportList();
      reportListFuture.then((reportlist) {
        setState(() {
          this.reportlist = reportlist;
          this.count = reportlist.length;
        });
      });
    });
  }

  void getReportmapId() {
    Future<List<Report>> reportListFuture = databaseHelper.getNewreportid();
    reportListFuture.then((reportlist) {
      setState(() {
        this.reportmapid = reportlist;
      });
    });
  }

  Future<void> _neverSatisfied(int position) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete report?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure want to discard this report?')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Discard'),
              onPressed: () {
                _delete(context, reportlist[position]);
                Navigator.of(context).pop();
                Flushbar(
                  title: "Report Deleted Successfully",
                  message: "All tasks associated with report got trashed.",
                  duration: Duration(seconds: 3),
                  icon: Icon(
                    Icons.delete_forever,
                    size: 28.0,
                    color: Colors.red,
                  ),
                  aroundPadding: EdgeInsets.all(8),
                  borderRadius: 8,
                  leftBarIndicatorColor: Colors.red,
                ).show(context);
              },
            ),
          ],
        );
      },
    );
  }
}