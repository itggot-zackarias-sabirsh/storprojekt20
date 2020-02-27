require 'slim'
require 'sinatra'
require 'sqlite3'
require 'BCrypt'
require_relative './model.rb'

enable :sessions

db = connect_to_db()

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

            password_digest = BCrypt::Password.create(password)
            p password_digest
            result = new_user(username, password_digest)
            p result
            redirect('/register_confirmation')
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

        password_digest = db.execute("SELECT password_digest FROM users WHERE username = (?)", username).first['password_digest']
        p password_digest

        if BCrypt::Password.new(password_digest) == password
            user_id = login(username)
            p user_id
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

get('/register_confirmation') do
    slim(:register_confirmation)
end

get('/home') do
 slim(:home)
end

get ('/error') do
    slim(:error)
end