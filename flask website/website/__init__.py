# this file is going to make the website folder a python package
# we can import the website folder and whatever is inside the init file will run automatically 

from flask import Flask
from flask_sqlalchemy import SQLAlchemy     # set up database with SQLAlchemy
from os import path
from flask_login import LoginManager

db = SQLAlchemy()   #define a new database object
DB_NAME = "database.db"     #database name (you can call it whatever you want)

def create_app():
    app = Flask(__name__)   # initialize app.  __name__ represents the name of the file 
    app.config['SECRET_KEY'] = 'san antonio'    # this will encrypt or secure the cookies and session data related to our website (in production don't share with anyone)
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'      #sql alchemy database is stored at this location
    db.init_app(app)    #initialize database by giving it our flask app

    from .views import views
    from .auth import auth

    app.register_blueprint(views, url_prefix='/')
    app.register_blueprint(auth, url_prefix='/')

    from .models import User, Note    # we need to make sure that we load the models.py file and defines the classes before we initialize or create the database.

    create_database(app)

    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'     # where do we need to go if we're not logged in 
    login_manager.init_app(app)

    @login_manager.user_loader      # this is telling flask how we load a user
    def load_user(id):
        return User.query.get(int(id))      # this defaults to getting primary key so we don't have to do id=id
    
    return app

def create_database(app):
    if not path.exists('website/' + DB_NAME):
        with app.app_context():
            db.create_all()
        print('Created Database!')