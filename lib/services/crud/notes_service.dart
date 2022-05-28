import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mynote/services/crud/crud_exception.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  static final NotesService _share = NotesService._shareInstance();
  NotesService._shareInstance() {
    _noteStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _noteStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _share;

  late final StreamController<List<DatabaseNote>> _noteStreamController;

  Stream<List<DatabaseNote>> get allNotes => _noteStreamController.stream;

  Future<void> _cacheNote() async {
    final allNotes = await getAllNote();
    _notes = allNotes.toList();
    _noteStreamController.add(_notes);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFoundUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure note exists
    await getNote(id: note.id);

    // update DB
    final updateCount = await db
        .update(noteTable, {textColumn: text, isSynciedWithCloudColumn: 0});

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updateNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updateNote.id);
      _notes.add(updateNote);
      _noteStreamController.add(_notes);
      return updateNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final note = await db.query(noteTable);

    return note.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFoundNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _noteStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.delete(noteTable);
    _notes = [];
    _noteStreamController.add(_notes);
    return result;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _noteStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // make sure owner exsist in database in current user
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFoundUser();
    }

    const text = '';
    // create note in database
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSynciedWithCloudColumn: 1
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSynciedWithClould: true,
    );

    _notes.add(note);
    _noteStreamController.add(_notes);

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isEmpty) {
      throw CouldNotFoundUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      db.close();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenExcception {
      // empty
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenExcception();
    }
    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create user table

      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);

      await _cacheNote();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryExcception();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'person id = $id , email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSynciedWithClould;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSynciedWithClould,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSynciedWithClould = (map[isSynciedWithCloudColumn] as int)==1 ? true : false;

  @override
  String toString() =>
      'person id = $id , userId = $userId , synicedClould = $isSynciedWithClould , text = $text';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'myNoteDatabase.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSynciedWithCloudColumn = 'is_syncied_with_clould';
const createNoteTable = '''CREATE TABLE "note" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT NOT NULL,
	"is_syncied_with_clould"	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);
''';
const createUserTable = ''' 
    CREATE TABLE IF NOT EXISTS "user" (
  	"id"	INTEGER NOT NULL,
    "email"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );
''';
