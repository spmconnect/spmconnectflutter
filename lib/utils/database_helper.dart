import 'package:path/path.dart';
import 'package:spmconnectapp/models/images.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:spmconnectapp/models/report.dart';
import 'package:spmconnectapp/models/tasks.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database; // Singleton Database

// ** Table column names for Report
  String reportTable = 'servicerpt_tbl';
  String colId = 'id';
  String colProjectno = 'projectno';
  String colReportno = 'reportno';
  String colCustomer = 'customer';
  String colPlantloc = 'plantloc';
  String colContactname = 'contactname';
  String colAuthorby = 'authorby';
  String colEquipment = 'equipment';
  String colTechname = 'techname';
  String colDate = 'date';
  String colfurteractions = 'furtheractions';
  String colcustcomments = 'custcomments';
  String colcustrep = 'custrep';
  String colcustemail = 'custemail';
  String colcustcontact = 'custcontact';
  String colreportmapid = 'reportmapid';
  String colreportpublished = 'reportpublished';
  String colreportsigned = 'reportsigned';
  String colspare1 = 'spare1';
  String colspare2 = 'spare2';
  String colspare3 = 'spare3';
  String colspare4 = 'spare4';
  String colspare5 = 'spare5';

// ** Table column names for tasks
  String taskTable = 'tasks_tbl';
  String coltaskId = 'id';
  String coltaskreportid = 'reportid';
  String coltaskItem = 'item';
  String coltaskStartTime = 'starttime';
  String coltaskEndTime = 'endtime';
  String coltaskWork = 'workperformed';
  String coltaskHours = 'hours';
  String coltaskDate = 'date';
  String coltaskPublished = 'taskpublished';
  String coltaskspare1 = 'taskspare1';
  String coltaskspare2 = 'taskspare2';
  String coltaskspare3 = 'taskspare3';
  String coltaskspare4 = 'taskspare4';
  String coltaskspare5 = 'taskspare5';

  // ** Table column names for tasks
  String imageTable = 'image_tbl';
  String colimageReportid = 'reportid';
  String colimageIdentifier = 'identifier';
  String colimageName = 'name';
  String colimageWidth = 'width';
  String colimageHeight = 'height';
  String colimagespare1 = 'spare1';
  String colimagespare2 = 'spare2';
  String colimagespare3 = 'spare3';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    //String path = directory.path + 'servicereport.db';
    String path = join(directory.path, "servicereport.db");

    // Open/create the database at a given path
    var reportDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return reportDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $reportTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colProjectno TEXT, $colReportno TEXT, '
        '$colCustomer TEXT, $colPlantloc TEXT,$colContactname TEXT,$colAuthorby TEXT,$colEquipment TEXT,$colTechname TEXT, $colDate TEXT, '
        '$colfurteractions TEXT,$colcustcomments TEXT,$colcustrep TEXT,$colcustemail TEXT,$colcustcontact TEXT,$colreportmapid INTEGER,'
        '$colreportpublished INTEGER,$colreportsigned INTEGER, $colspare1 TEXT, $colspare2 TEXT, $colspare3 TEXT, $colspare4 TEXT, $colspare5 TEXT)');
    await db.execute(
        'CREATE TABLE $taskTable($coltaskId INTEGER PRIMARY KEY AUTOINCREMENT, $coltaskreportid TEXT, '
        '$coltaskItem TEXT, $coltaskStartTime TEXT, $coltaskEndTime TEXT,$coltaskWork TEXT,$coltaskHours TEXT,$coltaskDate TEXT,$coltaskPublished INTEGER,'
        '$coltaskspare1 TEXT, $coltaskspare2 TEXT, $coltaskspare3 TEXT, $coltaskspare4 TEXT, $coltaskspare5 TEXT)');
    await db.execute(
        'CREATE TABLE $imageTable($colimageReportid TEXT , $colimageIdentifier TEXT, '
        '$colimageName TEXT, $colimageWidth INTEGER, $colimageHeight INTEGER,$coltaskspare1 TEXT, $coltaskspare2 TEXT, $coltaskspare3 TEXT)');
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getReportMapList() async {
    Database db = await this.database;
    //		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(reportTable, orderBy: '$colreportmapid DESC');
    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> inserReport(Report report) async {
    Database db = await this.database;
    var result = await db.insert(reportTable, report.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateReport(Report report) async {
    var db = await this.database;
    var result = await db.update(reportTable, report.toMap(),
        where: '$colId = ?', whereArgs: [report.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteReport(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $reportTable WHERE $colId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $reportTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Report>> getReportList() async {
    var reportMapList =
        await getReportMapList(); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Report> reportList = List<Report>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reportList.add(Report.fromMapObject(reportMapList[i]));
    }

    return reportList;
  }

  Future<List<Report>> getNewreportid() async {
    var reportidMapList =
        await getNewreportidMap(); // Get 'Map List' from database
    int count =
        reportidMapList.length; // Count the number of map entries in db table

    List<Report> reportmapidList = List<Report>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reportmapidList.add(Report.fromMapObject(reportidMapList[i]));
    }
    return reportmapidList;
  }

  Future<List<Map<String, dynamic>>> getNewreportidMap() async {
    Database db = await this.database;
    var result = await db.rawQuery(
        'SELECT * FROM $reportTable WHERE $colreportmapid = (SELECT MAX($colreportmapid) FROM $reportTable) ');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }

//*! Task table commands

  Future<int> insertTask(Tasks task) async {
    Database db = await this.database;
    var result = await db.insert(taskTable, task.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateTask(Tasks task) async {
    var db = await this.database;
    var result = await db.update(taskTable, task.toMap(),
        where: '$coltaskId = ?', whereArgs: [task.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteTask(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $taskTable WHERE $coltaskId = $id');
    return result;
  }

  Future<int> deleteAllTasks(String reportmapid) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM $taskTable WHERE $coltaskreportid = $reportmapid');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCountTask() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $taskTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Tasks>> getTasksList(String reportid) async {
    var taskMapList =
        await getTasksMapList(reportid); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Tasks> tasklist = List<Tasks>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      tasklist.add(Tasks.fromMapObject(taskMapList[i]));
    }

    return tasklist;
  }

  Future<List<Map<String, dynamic>>> getTasksMapList(String reportid) async {
    Database db = await this.database;

    var result = await db.rawQuery(
        'SELECT * FROM $taskTable where $coltaskreportid ="$reportid" order by $coltaskId ASC');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }

  //*! Sharepoint REST API QUERIES

  Future<List<Report>> getReportListUnpublished() async {
    var reportMapList =
        await getReportMapListUnpublished(); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Report> reportList = List<Report>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      reportList.add(Report.fromMapObject(reportMapList[i]));
    }
    return reportList;
  }

  Future<List<Map<String, dynamic>>> getReportMapListUnpublished() async {
    Database db = await this.database;
    int published = 0;
    int signed = 1;
    var result = await db.rawQuery(
        'SELECT * FROM $reportTable where $colreportpublished = $published AND $colreportsigned = $signed order by $colreportmapid ASC');
    return result;
  }

// Getting all unpublished task

  Future<List<Tasks>> getTaskListUnpublished() async {
    var reportMapList =
        await getTaskMapListUnpublished(); // Get 'Map List' from database
    int count =
        reportMapList.length; // Count the number of map entries in db table

    List<Tasks> taskList = List<Tasks>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      taskList.add(Tasks.fromMapObject(reportMapList[i]));
    }

    return taskList;
  }

  Future<List<Map<String, dynamic>>> getTaskMapListUnpublished() async {
    Database db = await this.database;
    int published = 0;
    var result = await db.rawQuery(
        'SELECT * FROM $taskTable where $coltaskPublished = $published order by $coltaskId ASC');
    return result;
  }

//*! Image table commands

  Future<int> insertImage(Images image) async {
    Database db = await this.database;
    var result = await db.insert(imageTable, image.toMap());
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateImage(Images image) async {
    var db = await this.database;
    var result = await db.update(taskTable, image.toMap(),
        where: '$colimageReportid = ?', whereArgs: [image.reportid]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteImages(String id) async {
    var db = await this.database;
    int result = await db
        .rawDelete('DELETE FROM $imageTable WHERE $colimageReportid = $id');
    return result;
  }

  Future<int> deleteAllImages(String reportmapid) async {
    var db = await this.database;
    int result = await db.rawDelete(
        'DELETE FROM $imageTable WHERE $colimageReportid = $reportmapid');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCountImages() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $imageTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Images>> getImageList(String reportid) async {
    var taskMapList =
        await getImagesMapList(reportid); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Images> tasklist = List<Images>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      tasklist.add(Images.fromMapObject(taskMapList[i]));
    }

    return tasklist;
  }

  Future<List<Map<String, dynamic>>> getImagesMapList(String reportid) async {
    Database db = await this.database;

    var result = await db.rawQuery(
        'SELECT * FROM $imageTable where $colimageReportid =$reportid');
    //var result = await db.query(reportTable, orderBy: '$colProjectno DESC');
    return result;
  }
}
