require 'slim'
require 'sinatra'
require 'sqlite3'
require 'BCrypt'
require 'mime-types'
require_relative './model.rb'

enable :sessions

# db = connect_to_db()

def set_error(error_message)
    session[:error] = error_message
end

get('/')  do
    slim(:start)
end 

post('/users/new') do

    username = params["username"]
    password = params["password"]
    password_confirmation = params["password_confirmation"]

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
            redirect('/home')
        else
            set_error("Passwords don't match")
            redirect('/error')
        end
    else
        set_error("Username alreade exists")
        redirect('/error')
    end
end

post('/users/login') do
    username = params["username"]
    password = params["password"]
    
    validation = username_validation(username)
    
    if validation.any?

        password_digest = get_password_by_username(username)
        p password_digest

        if validate_password(password_digest) == password
            user_id = login(username)
            p user_id
            session[:user_id] = user_id
            redirect('/home')
        else
            set_error("Password is not correct")
            redirect('/error')
        end
    else
        set_error("Username does not exist")
        redirect('/error')
    end
end

before do
    MIME::Types.type_for('css')
    # session[:user_id] = 4
    path = request.path_info
    blacklist = ['/', '/users/login', '/users/new']
    redirect = true

    blacklist.each do |e|
        if path == e
            redirect = false
        end
    end
    
    if session[:user_id].nil? and redirect
        redirect('/')
    end

    # all_post_id.each do |post_id|
    #     post_tags = get_tags_by_post_id(post_id)
    # end
end

get('/users/register_confirmation') do
    slim(:register_confirmation)
end

get('/create_post') do
    slim(:"post/create")
end

post('/post/create') do
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
    
    
    redirect('/home')
end

post("/post/delete") do
    delete_post_id = params["delete_post_id"].to_i

    delete_post_by_id(delete_post_id)
    delete_tags_by_id(delete_post_id)

    redirect('/home')
end


post("/post/update") do
    update_post_id = params["update_post_id"].to_i
    update_text = params["update_text"].to_s

    update_post_by_id(update_post_id, update_text)

    redirect('/home')
end

get('/home') do
    slim(:home, locals:{current_user_id: session[:user_id], 
        current_username: get_username_by_id(session[:user_id]), 
        all_post_info: get_all_post_info()})      
end

get('/error') do
    slim(:error)
end

