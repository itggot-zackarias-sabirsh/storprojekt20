require 'slim'
require 'sinatra'
require 'sqlite3'
require 'BCrypt'

def db()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    return db
end


def get_username_by_id(user_id)
    return db.execute("SELECT username FROM users WHERE user_id = (?)", user_id).first['username']
end

def username_validation(username)
    validation = db.execute("SELECT username FROM users WHERE username = (?)", username)
    return validation
end

def new_user(username, password_digest)
    result = db.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", [username, password_digest])
    return result
end

def login(username)
    result = db.execute("SELECT user_id FROM users WHERE username = (?)", username).first['user_id']
    return result
end

def password(username)
    result = db.execute("SELECT password_digest FROM users WHERE username = (?)", username).first['password_digest']
    return result
end