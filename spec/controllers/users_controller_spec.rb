require 'spec_helper'
require 'rails_helper'
require 'simplecov'
SimpleCov.start

describe UsersController do
  context 'Creating a new user' do
    it 'should redirect to the Login Page' do
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      expect(response).to redirect_to(login_path)
    end
    it 'should add a user to the database' do
      test_size = User.all.size
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      expect(User.all.size).to equal(test_size+1)
    end
    it 'should redirect to the Sign Up Page if the username already taken' do
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username2@gmail.com', :password2 => 'password'}}
      expect(response).to redirect_to(new_user_path)
    end
    it 'should redirect to the Sign Up Page if the email already taken' do
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      post :create, {:user => {:username => 'username2', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      expect(response).to redirect_to(new_user_path)
    end
    it 'should redirect to the Sign Up Page if the passwords do not match' do
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password1'}}
      expect(response).to redirect_to(new_user_path)
    end
    it 'should not add a user to the database with a repeated username' do
      test_size = User.all.size
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username2@gmail.com', :password2 => 'password'}}
      expect(User.all.size).to equal(test_size+1)
    end
    it 'should not add a user to the database with a repeated email' do
      test_size = User.all.size
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      post :create, {:user => {:username => 'username2', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password'}}
      expect(User.all.size).to equal(test_size+1)
    end
    it 'should not add a user to the database if the passwords do not match' do
      test_size = User.all.size
      post :create, {:user => {:username => 'username1', :password => 'password', :email => 'username1@gmail.com', :password2 => 'password1'}}
      expect(User.all.size).to equal(test_size)
    end
  end
end