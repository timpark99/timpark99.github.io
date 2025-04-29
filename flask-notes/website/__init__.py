from flask import Flask     
from flask_sqlalchemy import SQLAlchemy     
from os import path    

db = SQLAlchemy()   
DB_NAME = "notes.db" 

def create_app():
    app = Flask(__name__) 
    app.config['SECRET_KEY'] = 'devkey'   
    app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}' 
    db.init_app(app)   

    from .routes import routes
    app.register_blueprint(routes)  
    
    with app.app_context():
        from .models import Note 
        db.create_all()  

    return app