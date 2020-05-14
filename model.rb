require 'slim'
require 'sinatra'
require 'sqlite3'
require 'BCrypt'

# Calls database
#
def db()
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    return db
end

# Gets a user's username from their id
#
# @param [Integer] user_id, A user's id
#
# @return [String] The user's username
def get_username_by_id(user_id)
    return db.execute("SELECT username FROM users WHERE user_id = (?)", user_id).first['username']
end

# Checks for already existing username
#
# @param [Integer] user_id, Username
#
# @return [String] The user's username
def username_validation(username)
    validation = db.execute("SELECT username FROM users WHERE username = (?)", username)
    return validation
end

# Registers new user
#
# @param [String] username, Username
# @param [String] password_digest, Encrypted password
def new_user(username, password_digest)
    result = db.execute("INSERT INTO users (username, password_digest) VALUES (?, ?)", [username, password_digest])
    return result
end

# Gets users ID from their username
#
# @return [String] The user's username
#
def login(username)
    result = db.execute("SELECT user_id FROM users WHERE username = (?)", username).first['user_id']
    return result
end

# Encrypts password
#
# @param [String] Unencrypted password
#
# @param [String] Encrypted password
#
def new_password(password)
    result = BCrypt::Password.create(password)
    return result
end

# Checks that password is correct
#
# @param [String] password_digest, Encrypted password
#
# @return [String] Unencrypted password
#
def validate_password(password_digest)
    result = BCrypt::Password.new(password_digest)
    return result
end

# Gets a user's password from their username
#
# @param [String] username, The user's username
#
# @return [String] The user's encrypted password
def get_password_by_username(username)
    result = db.execute("SELECT password_digest FROM users WHERE username = (?)", username).first['password_digest']
    return result
end

# Checks for alredy existing tag, and adds new one to list
#
# @param [String] tag_each, The tag
#
def new_tag(tag_each)
    tag_validation = db.execute("SELECT tag_name FROM tags WHERE tag_name = (?)", tag_each)

    if tag_validation.empty?
        result = db.execute("INSERT INTO tags (tag_name) VALUES (?)", [tag_each])
        return result
    end
end

# Gets a tag's id from its name
#
# @param [String] tag_each, The tag
#
# @return [Integer] The tag's ID
def get_tag_id_by_name(tag_each)
    result = db.execute("SELECT tag_id FROM tags WHERE tag_name = (?)", tag_each).first['tag_id']
    return result
end

# Gets a tag's name from post's ID
#
# @param [Integer] id, Post ID
#
# @return [String] The tag's name
#
def get_tags_by_post_id(id)
    result = db.execute("SELECT post_tags_join.post_id, tags.tag_name FROM post_tags_join INNER JOIN tags ON post_tags_join.post_tag = tags.tag_id WHERE post_id =(?)", id)
    return result
end

# Registers new post
#
# @param [String] post_text, The text of the post
#
# @param [String] post_user, User who posted post
#
def new_post(post_text, post_user)
    result = db.execute("INSERT INTO posts (post_text, post_user) VALUES (?, ?)", [post_text, post_user])
end

# Deletes a post by it's ID
#
# @param [Integer] delete_post_id, Post ID
#
def delete_post_by_id(delete_post_id)
    result = db.execute("DELETE FROM posts WHERE post_id =(?)", delete_post_id)
    return result
end

# Deletes a post's tags by it's ID
#
# @param [Integer] delete_post_id, Post ID
#
def delete_tags_by_id(delete_post_id)
    result = db.execute("DELETE FROM post_tags_join WHERE post_id =(?)", delete_post_id)
    return result
end

# Updates a post's text by it's ID
#
# @param [Integer] update_post_id, Post ID
#
# @param [String] update_text, The text of the post
#
def update_post_by_id(update_post_id, update_text)
    result = db.execute("UPDATE posts SET post_text = (?) WHERE post_id = (?)", [update_text, update_post_id])
    return result
end

# Gets ID of latest posted post
#
def get_post_id()
    result = db.execute("SELECT MAX(post_id) from posts").first['MAX(post_id)']
    return result
end

# Registers a post's tags in separate join table
#
# @param [Integer] latest_post_id, Post ID
#
# @param [Integer] tag_id, The tag's ID
#
def post_tags_join(latest_post_id, tag_id)
    result = db.execute("INSERT INTO post_tags_join (post_id, post_tag) VALUES (?, ?)", [latest_post_id, tag_id])
end

# Gets all data from posts table
#
def get_all_post_info()
    result = db.execute("SELECT * from posts")
    return result
end

# Gets all post info from ID
#
# @param [Integer] post_id, Post ID
#
def get_post_info_from_id(post_id)
    result = db.execute("SELECT * from posts WHERE post_id = (?)", post_id).first['post_id']
    return result
end

# Gets all post ID's
#
def all_post_id()
    all_post_id = db.execute("SELECT post_id FROM posts").first['post_id']
end

# Gets post's ID from tags name
#
# @param [String] tag_name, The tag's name
#
def get_post_id_from_tag_name(tag_name)
    tag_id = db.execute("SELECT tag_id from tags WHERE tag_name = (?)", tag_name).first['tag_name']
    result = db.execute("SELECT post_id from post_tags_join WHERE tag_id = (?)", tag_id).first['post_id']
    return result
end
