require 'slim'
require 'sinatra'
require 'sqlite3'
require 'BCrypt'
require 'mime-types'
require_relative './model.rb'

enable :sessions


# db = connect_to_db()

before do
    # session[:user_id] = 4
    path = request.path_info
    blacklist = ['/', '/users/login', '/users/new', '/error']
    redirect = true
    
    blacklist.each do |e|
        if path == e
            redirect = false
        end
    end
    
    p path
    
    if session[:user_id].nil? and redirect
        redirect('/')
    end
    
end

# Display Landing Page
#
get('/')  do
    session[:user_id] = nil
    slim(:index)
end 

# Attempts register and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
#
post('/users/new') do

    username = params["username"]
    password = params["password"]
    password_confirmation = params["password_confirmation"]

    if username.empty? || password.empty?
        set_error("Fields missing")
        redirect('/error')
    end
    
    validation = username_validation(username)
    if validation.empty?
        if  password == password_confirmation

            password_digest = new_password(password)
            p password_digest
            result = new_user(username, password_digest)
            p result
            user_id = login(username)
            p user_id
            session[:user_id] = user_id
            redirect('/blogs')
        else
            set_error("Passwords don't match")
            redirect('/error')
        end
    else
        set_error("Username alreade exists")
        redirect('/error')
    end
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password
#
post('/users/login') do
    username = params["username"]
    password = params["password"]
    
    validation = username_validation(username)

    if session[:attempt].nil?
        session[:attempt] = Time.now
    elsif Time.now - session[:attempt] < 20 
        session[:error] = "Cannot log in at this moment. Wait a minute and try again"
        redirect('/error')
    end 
    # p Time.now - session[:attempt]
    session[:attempt] = Time.now
    
    if validation.any?

        password_digest = get_password_by_username(username)
        p password_digest

        if validate_password(password_digest) == password
            user_id = login(username)
            p user_id
            session[:user_id] = user_id
            redirect('/blogs')
        else
            set_error("Password is not correct")
            redirect('/error')
        end
    else
        set_error("Username does not exist")
        redirect('/error')
    end
end

# Displays register confirmation
#
get('/users/register_confirmation') do
    slim(:register_confirmation)
end

# Creates a new article and redirects to '/blogs'
#
# @param [String] post_text, The text of the article
# @param [String] tag_name, The name of tags in article
#
post('/blog/new') do
    post_text = params["post_text"]
    tag_name = params["tag_name"].split" "
    p tag_name

    
    post_user = (session[:user_id])
    new_post(post_text, post_user)
    post_id = get_post_id()
    p post_id
    
    
    tag_name.each do |tag_each| 
        p tag_each
        new_tag(tag_each)    
        tag_id = get_tag_id_by_name(tag_each) 
        post_tags_join(post_id, tag_id)
    end
    
    
    redirect('/blogs')
end

# Deletes an existing article and redirects to '/blogs'
#
# @param [Integer] post_id, The ID of the article
#
post("/blog/delete") do
    delete_post_id = params["delete_post_id"].to_i

    delete_post_by_id(delete_post_id)
    delete_tags_by_id(delete_post_id)

    redirect('/blogs')
end

# Updates an existing article and redirects to '/blogs'
#
# @param [Integer] post_id, The ID of the article
# @param [String] post_text, The text of the article
#
post("/blog/update") do
    update_post_id = params["update_post_id"].to_i
    update_text = params["update_text"].to_s

    update_post_by_id(update_post_id, update_text)

    redirect('/blogs')
end

post("blog/:id") do
    tag_name = params["tag_name"].to_s
    post_id = get_post_id_from_tag_name(tag_name)

end

# Displays blogs page
#
get('/blogs') do
    slim(:blogs, locals:{current_user_id: session[:user_id], 
        current_username: get_username_by_id(session[:user_id]), 
        all_post_info: get_all_post_info()})      
end

# Defines error
# @param [String] error_message, Error message text
#
def set_error(error_message)
    session[:error] = error_message
end

# Displays an error message
#
get('/error') do
    slim(:error)
end

