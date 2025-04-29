# where the login page is.  auth is for authentication

from flask import Blueprint, render_template, request, flash, redirect, url_for    # flash is used for error messaging alerts to user
from .models import User
from werkzeug.security import generate_password_hash, check_password_hash   
from . import db
from flask_login import login_user, login_required, logout_user, current_user

# import a few things from flask login that are going to allow me to hash a password.  hash is a way to secure a password such that you are never storing a password in plain text
# a hashing function is a one way function such that it does not have an inverse

auth = Blueprint('auth', __name__)

@auth.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':    # if we are actually signing in 
        email = request.form.get('email')
        password = request.form.get('password')

        user = User.query.filter_by(email=email).first()    # looking for specific entry in database; first() grabs first entry
        if user:
            if check_password_hash(user.password, password):
                flash('Logged in successfully!', category='success')
                login_user(user, remember=True)     # remember allows user to stay logged in unless history is cleared or browser restarts
                return redirect(url_for('views.home'))
            else:
                flash('Incorrect password, try again.', category='error')
        else:
            flash('Email does not exist.', category='error')
    return render_template("login.html", user=current_user)

@auth.route('/logout')
@login_required     # add a decorator which makes sure that we cannot access this route unless the user is logged in
def logout():
    logout_user()
    return redirect(url_for('auth.login'))      # bring user back to sign in page

@auth.route('/sign-up', methods=['GET', 'POST'])
def sign_up():
    if request.method == 'POST':
        email = request.form.get('email')
        first_name = request.form.get('firstName')
        password1 = request.form.get('password1')
        password2 = request.form.get('password2')

        user = User.query.filter_by(email=email).first()
        if user:
            flash('Email already exists.', category='error')
        elif len(email) < 4:
            flash('Email must be greater than 3 characters.', category='error')
        elif len(first_name) < 2:
            flash('First name must be greater than 1 character.', category='error')
        elif password1 != password2:
            flash('Passwords don\'t match.', category='error')
        elif len(password1) < 7:
            flash('Password must be at least 7 characters.', category='error')
        else:
            new_user = User(email=email, first_name=first_name, password=generate_password_hash(password1, method='pbkdf2:sha256'))        # User is from model.py file; sha256 is a hashing algorithm
            db.session.add(new_user)    # add user to database
            db.session.commit()# update database
            login_user(user, remember=True)     # they should be logged in after they sign up
            flash('Account created!', category='success')
            return redirect(url_for('views.home'))  # redirect user to home page of the website

    return render_template("sign_up.html", user=current_user)
