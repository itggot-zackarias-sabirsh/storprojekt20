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

def new_password(password)
    result = BCrypt::Password.create(password)
    return result
end

def validate_password(password_digest)
    result = BCrypt::Password.new(password_digest)
    return result
end

def get_password_by_username(username)
    result = db.execute("SELECT password_digest FROM users WHERE username = (?)", username).first['password_digest']
    return result
end

def new_tag(tag_each)
    tag_validation = db.execute("SELECT tag_name FROM tags WHERE tag_name = (?)", tag_each)

    if tag_validation.empty?
        result = db.execute("INSERT INTO tags (tag_name) VALUES (?)", [tag_each])
        return result
    end
end

def get_tag_id_by_name(tag_each)
    result = db.execute("SELECT tag_id FROM tags WHERE tag_name = (?)", tag_each).first['tag_id']
    return result
end

def get_tags_by_post_id(id)
    result = db.execute("SELECT post_tags_join.post_id, tags.tag_name FROM post_tags_join INNER JOIN tags ON post_tags_join.post_tag = tags.tag_id WHERE post_id =(?)", id)
    return result
end

def new_post(post_text, post_user)
    result = db.execute("INSERT INTO posts (post_text, post_user) VALUES (?, ?)", [post_text, post_user])
end

def get_post_id()
    result = db.execute("SELECT MAX(post_id) from posts").first['MAX(post_id)']
    return result
end

def post_tags_join(latest_post_id, tag_id)
    result = db.execute("INSERT INTO post_tags_join (post_id, post_tag) VALUES (?, ?)", [latest_post_id, tag_id])
end

def get_all_post_info()
    result = db.execute("SELECT * from posts")
    return result
end

def get_post_info_from_id(post_id)
    result = db.execute("SELECT * from posts WHERE post_id = (?)", post_id).first['post_id']
    return result
end

def all_post_id()
    all_post_id = db.execute("SELECT post_id FROM posts").first['post_id']
end

