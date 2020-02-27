require 'slim'
require 'sinatra'
require 'sqlite3'
require 'BCrypt'

def connect_to_db()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    return db
end

def username_validation(username)
    db = connect_to_db()
    validation = db.execute("SELECT username FROM users WHERE username = (?)", username)
    return validation
end

def new_user(username, password_digest)
    db = connect_to_db()
    result = db.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", [username, password_digest])
    return result
end

def login(username)
    db = connect_to_db()
    result = db.execute("SELECT user_id FROM users WHERE username = (?)", username)
    return result
end

def password(username)
    db = connect_to_db()
    result = db.execute("SELECT password_digest FROM users WHERE username = (?)", username)
    return result
end