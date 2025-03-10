# this file is going to make the website folder a python package
# we can import the website folder and whatever is inside the init file will run automatically 

from flask import Flask

def create_app():
    # initialize app
    app = Flask(__name__)   # __name__ represents the name of the file 
    app.config['SECRET_KEY'] = 'san antonio'    # this will encrypt or secure the cookies and session data related to our website
    # in production you never want to share the secret key with anybody

    from .views import views
    from .auth import auth

    app.register_blueprint(views, url_prefix='/')
    app.register_blueprint(auth, url_prefix='/')
    
    return app