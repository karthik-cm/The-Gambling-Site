# Using 'Sinatra' Web Development framework to implement a simple Bet web application - Roll A Dice
# This Ruby file contains all the necessary methods, DAO and Sinatra web framework related details
# Author: Karthik CM


#!/usr/bin/ruby

require 'sinatra'
require './user'



# enable sessions to store information
configure do
    enable :sessions
end




########################################## VIEWS - START ##########################################

# Home Page
get '/' do 
    redirect '/home'
end


# Home Page
get '/home' do
    erb :home
end


# Login Page
get '/login' do
    erb :login_user
end


# Register Page
get '/register' do
    erb :register_user
end


# Arena Page
get '/arena' do
    erb :arena
end

########################################## VIEWS - END ##########################################






########################################## FUNCTIONS - START ##########################################

# Images 
images = Hash.new("Images")
images = {
    1 => "/images/dice-img-1.png",
    2 => "/images/dice-img-2.png",
    3 => "/images/dice-img-3.png",
    4 => "/images/dice-img-4.png",
    5 => "/images/dice-img-5.png",
    6 => "/images/dice-img-6.png"
}

# method to render the dice images on Arena
def to_render_dice_images(choice, random, betamount, images)
    session[:choice] = choice
    session[:random] = random
    session[:betamount] = betamount
    session[:dice_img_url] = images[random]
end





# Request to handle registration new users
# Type : POST
post '/register' do
    username = params[:username]
    password = params[:password]

    user_exist = check_if_user_exist(username)

    if user_exist
        session[:message] = "Error: Username already exists. Try again!"
        redirect '/register'
    end

    insert_new_user_details(username, password)
    session[:message] = "User registered successfully! Proceed to Login"
    redirect '/register'
end


# Request to handle login existing user
# Type : POST
post '/login' do
    username = params[:username]
    password = params[:password]
    
    # check if user exists already
    user_exist = check_if_user_exist(username)

    puts "user_exist = #{user_exist}"

    if user_exist
        user_details = get_user_details(username, password)

        puts "user_details = #{user_details}"

        if user_details != nil
            # valid user - proceed to Arena page
            
            # add necessary params to session
            session[:loginFlag] = true
            session[:username] = username

            # add statistics history details - wins / loss / profit details to session
            session[:total_won] = user_details.total_won
            session[:total_lost] = user_details.total_lost
            session[:total_profit] = user_details.total_profit

            # also add current session statistics - wins / loss / profit starting with 0
            session[:curr_total_won] = 0
            session[:curr_total_lost] = 0
            session[:curr_total_profit] = 0

            redirect '/arena'
        end
    end

    session[:message] = "Error: Invalid Username / Password"
    redirect '/login'
end


# Request to handle place bet
# Type : POST
post '/bet' do
    choice = params[:choice].to_i
    betamount = params[:betamount].to_i

    # generate a random number from 1 to 6 (fair dice with 6 faces)
    random = rand(1..6)

    # to render the dice images
    to_render_dice_images(choice, random, betamount, images)

    total_won = session[:curr_total_won]
    total_lost = session[:curr_total_lost]
    profit = session[:curr_total_profit]

    if choice == random
        session[:status] = "You Won! &#128526;"
        
        # calculate money won and update the total won, profits
        won = 2 * betamount

        session[:curr_total_won] = total_won + won
        session[:curr_total_profit] = profit + won
    else
        session[:status] = "You Lost! &#128533;"

        session[:curr_total_lost] = total_lost + betamount
        session[:curr_total_profit] = profit - betamount
    end

    redirect '/arena'
end


# Request to handle logout 
# Type : POST
post '/logout' do
    username = session[:username]

    # store the current session details to database
    store_current_session_data(username)

    session.clear

    redirect '/home'
end

########################################## FUNCTIONS - END ##########################################






########################################## DAO METHODS - START ##########################################

# method to check if the user already exists in the database
# params: username
# return: true/false
def check_if_user_exist(username)
    if(User.first(username: username))
        return true
    else
        return false
    end
end


# method to insert new user details to database
# params: username, password
# return: void
def insert_new_user_details(username, password)
    User.create(username: username, password: password, total_won: "0", total_lost: "0", total_profit: "0")
end


# method to get user details from database using username and password
# params: username, password
# return: user details array of length 1
def get_user_details(username, password)
    return User.first(username: username, password: password)
end



# method to update the current session statistics - won, lost and profit to database
# params: username
# return: void
def store_current_session_data(username)
    # update the total won, total lost and total profit
    total_won = session[:total_won] + session[:curr_total_won]
    total_lost = session[:total_lost] + session[:curr_total_lost]
    total_profit = session[:total_profit] + session[:curr_total_profit]

    user = User.first(username: username)
    user.update(total_won: total_won)
    user.update(total_lost: total_lost)
    user.update(total_profit: total_profit)
end

########################################## DAO METHODS - END ##########################################






########################################## DATABASE DETAILS - START ##########################################

# sqlite3
# database  -   user.db
# table     -   Users

# CREATE TABLE IF NOT EXISTS Users(
#     ID INTEGER PRIMARY KEY AUTOINCREMENT,
#     USERNAME TEXT NOT NULL UNIQUE,
#     PASSWORD TEXT NOT NULL,
#     TOTAL_WON INT DEFAULT 0,
#     TOTAL_LOST INT DEFAULT 0,
#     TOTAL_PROFIT INT DEFAULT 0
# );

########################################## DATABASE DETAILS - END ##########################################
