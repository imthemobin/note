class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

// C in CRUD
class CouldNotCreateNoteException extends CloudStorageExceptions{}

// R in CRUD
class CouldNotGetAllNotesException extends CloudStorageExceptions{}

// U in CRUD
class CouldNotUpdateNoteException extends CloudStorageExceptions{}

// D in CRUD
class CouldNotDeleteNoteException extends CloudStorageExceptions{}
