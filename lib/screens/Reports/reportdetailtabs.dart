import 'package:flutter/material.dart';
import 'package:spmconnectapp/Resource/database_helper.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/screens/Reports/image_picker.dart';
import 'package:spmconnectapp/screens/Reports/report_detail_pg1.dart';
import 'package:spmconnectapp/screens/Reports/task_list.dart';
import 'package:spmconnectapp/screens/Reports/report_detail_pg3.dart';
import 'package:spmconnectapp/screens/Reports/report_detail_pg4.dart';
import 'package:intl/intl.dart';
import 'package:spmconnectapp/themes/appTheme.dart';

class ReportDetTab extends StatefulWidget {
  final DBProvider helper;
  final String appBarTitle;
  final Report report;

  ReportDetTab(this.report, this.appBarTitle, this.helper);
  @override
  State<StatefulWidget> createState() {
    return _ReportDetTabState(this.report, this.appBarTitle);
  }
}

class _ReportDetTabState extends State<ReportDetTab> {
  String appBarTitle;

  Report report;
  _ReportDetTabState(this.report, this.appBarTitle);
  PageController controller = PageController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(appBarTitle + ' - ' + report.getreportno),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => movetolastscreen(),
        ),
      ),
      body: PageView(
        controller: controller,
        children: <Widget>[
          ReportDetail(report),
          TaskList(report.getreportno, widget.helper),
          ReportDetail3(report),
          ImagePicker(report.getreportno),
          ReportDetail4(report, widget.helper),
        ],
        onPageChanged: (int index) {
          if (report.getprojectno.length == 0 && index == 1) {
            _showAlertDialog('Error!', 'Project number cannot be empty.');
            controller.jumpToPage(0);
          } else {
            if (index == 1)
              this.appBarTitle = 'Edit Tasks';
            else if (index == 0)
              this.appBarTitle = 'Edit Report';
            else if (index == 4)
              this.appBarTitle = 'Customer Info';
            else if (index == 3)
              this.appBarTitle = 'Attach Pictures';
            else
              this.appBarTitle = 'Report Comments';
            setState(() {
              _selectedTab = index;
            });
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.getTheme().backgroundColor,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedTab,
        onTap: (int index) {
          if (report.getprojectno.length == 0 &&
              (index == 1 || index == 2 || index == 3 || index == 4)) {
            _showAlertDialog('Error!', 'Project number cannot be empty.');
          } else {
            if (index == 1)
              this.appBarTitle = 'Edit Tasks';
            else if (index == 0)
              this.appBarTitle = 'Edit Report';
            else if (index == 3)
              this.appBarTitle = 'Attach Images';
            else if (index == 4)
              this.appBarTitle = 'Customer';
            else
              this.appBarTitle = 'Comments';
            setState(() {
              _selectedTab = index;
              controller.jumpToPage(index);
            });
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            title: Text('Details'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            title: Text('Tasks'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            title: Text('Comments'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            title: Text('Pictures'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            title: Text('Customer'),
          ),
        ],
      ),
    );
  }

  Future<void> movetolastscreen() async {
    await _save();
    Navigator.pop(context, true);
  }

  Future<void> _save() async {
    //movetolastscreen();

    int result;
    if (report.getId != null) {
      // Case 1: Update operation
      result = await widget.helper.updateReport(report);
    } else {
      // Case 2: Insert Operation
      if (report.getprojectno.length > 0) {
        report.getdate =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
        result = await widget.helper.inserReport(report);
      }
    }
    if (result != 0) {
      // Success
      // _showAlertDialog('SPM Connect', 'Report Saved Successfully');
    } else {
      // Failure
      _showAlertDialog('SPM Connect', 'Problem Saving Report');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
