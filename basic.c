#include <stdio.h>
#include <stdlib.h>
#include <sqlite3.h>

static int execute(sqlite3 *db, const char *sql)
{
    char *err = NULL;

    int rc = sqlite3_exec(db, sql, 0, 0, &err);

    if (rc != SQLITE_OK)
    {
        fprintf(stderr, "SQL error: %s\n", err);
        sqlite3_free(err);
        return 0;
    }

    return 1;
}

int main()
{
    sqlite3 *db;

    if (sqlite3_open("tutorlink.db", &db) != SQLITE_OK)
    {
        fprintf(stderr, "Could not open database.\n");
        return 1;
    }

    execute(db, "PRAGMA foreign_keys = ON;");

    const char *schema =

    // USERS
    "CREATE TABLE IF NOT EXISTS users ("
    "   id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "   email TEXT UNIQUE NOT NULL,"
    "   password_hash TEXT NOT NULL,"
    "   first_name TEXT NOT NULL,"
    "   last_name TEXT NOT NULL,"
    "   phone TEXT,"
    "   role TEXT NOT NULL CHECK(role IN ('student','tutor')),"
    "   profile_photo TEXT,"
    "   created_at DATETIME DEFAULT CURRENT_TIMESTAMP"
    ");"

    // TUTOR PROFILE
    "CREATE TABLE IF NOT EXISTS tutor_profiles ("
    "   user_id INTEGER PRIMARY KEY,"
    "   bio TEXT,"
    "   hourly_rate REAL NOT NULL,"
    "   years_experience INTEGER DEFAULT 0,"
    "   verified INTEGER DEFAULT 0,"
    "   avg_rating REAL DEFAULT 0,"
    "   total_reviews INTEGER DEFAULT 0,"
    "   FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE"
    ");"

    // SUBJECTS
    "CREATE TABLE IF NOT EXISTS subjects ("
    "   id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "   name TEXT UNIQUE NOT NULL"
    ");"

    // MANY TO MANY: TUTOR ↔ SUBJECT
    "CREATE TABLE IF NOT EXISTS tutor_subjects ("
    "   tutor_id INTEGER,"
    "   subject_id INTEGER,"
    "   PRIMARY KEY(tutor_id, subject_id),"
    "   FOREIGN KEY(tutor_id) REFERENCES users(id) ON DELETE CASCADE,"
    "   FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE"
    ");"

    // AVAILABILITY
    "CREATE TABLE IF NOT EXISTS availability ("
    "   id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "   tutor_id INTEGER NOT NULL,"
    "   weekday INTEGER NOT NULL,"
    "   start_time TEXT NOT NULL,"
    "   end_time TEXT NOT NULL,"
    "   FOREIGN KEY(tutor_id) REFERENCES users(id) ON DELETE CASCADE"
    ");"

    // BOOKINGS
    "CREATE TABLE IF NOT EXISTS sessions ("
    "   id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "   student_id INTEGER NOT NULL,"
    "   tutor_id INTEGER NOT NULL,"
    "   subject_id INTEGER NOT NULL,"
    "   start_datetime TEXT NOT NULL,"
    "   end_datetime TEXT NOT NULL,"
    "   status TEXT NOT NULL CHECK("
    "       status IN ('pending','confirmed','completed','cancelled')"
    "   ),"
    "   notes TEXT,"
    "   created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
    "   FOREIGN KEY(student_id) REFERENCES users(id),"
    "   FOREIGN KEY(tutor_id) REFERENCES users(id),"
    "   FOREIGN KEY(subject_id) REFERENCES subjects(id)"
    ");"

    // CHAT MESSAGES
    "CREATE TABLE IF NOT EXISTS messages ("
    "   id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "   sender_id INTEGER NOT NULL,"
    "   receiver_id INTEGER NOT NULL,"
    "   body TEXT NOT NULL,"
    "   sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
    "   read_flag INTEGER DEFAULT 0,"
    "   FOREIGN KEY(sender_id) REFERENCES users(id),"
    "   FOREIGN KEY(receiver_id) REFERENCES users(id)"
    ");"

    // REVIEWS
    "CREATE TABLE IF NOT EXISTS reviews ("
    "   id INTEGER PRIMARY KEY AUTOINCREMENT,"
    "   session_id INTEGER UNIQUE,"
    "   student_id INTEGER NOT NULL,"
    "   tutor_id INTEGER NOT NULL,"
    "   rating INTEGER CHECK(rating BETWEEN 1 AND 5),"
    "   comment TEXT,"
    "   created_at DATETIME DEFAULT CURRENT_TIMESTAMP,"
    "   FOREIGN KEY(session_id) REFERENCES sessions(id),"
    "   FOREIGN KEY(student_id) REFERENCES users(id),"
    "   FOREIGN KEY(tutor_id) REFERENCES users(id)"
    ");"

    // PERFORMANCE INDEXES
    "CREATE INDEX IF NOT EXISTS idx_users_role "
    "ON users(role);"

    "CREATE INDEX IF NOT EXISTS idx_sessions_tutor "
    "ON sessions(tutor_id);"

    "CREATE INDEX IF NOT EXISTS idx_sessions_student "
    "ON sessions(student_id);"

    "CREATE INDEX IF NOT EXISTS idx_messages_receiver "
    "ON messages(receiver_id);";

    if (!execute(db, schema))
    {
        sqlite3_close(db);
        return 1;
    }

    printf("Database initialized successfully.\n");

    sqlite3_close(db);

    return 0;
}