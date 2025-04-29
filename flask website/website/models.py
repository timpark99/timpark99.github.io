# we'll use this to store our database models
# we wanna have a database model for our users
# we wanna have a database model for our notes

from . import db    # importing from the current package which is the website folder the db object
from flask_login import UserMixin       # flask module that helps users login
from sqlalchemy.sql import func     # func gets current date and time

class Note(db.Model):       # you're telling the database software all Notes need to look like this
    id = db.Column(db.Integer, primary_key=True)
    data = db.Column(db.String(10000))
    date = db.Column(db.DateTime(timezone=True), default=func.now())
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))   # one to many relationship; lower case user because of ForeignKey


class User(db.Model, UserMixin):        # you're telling the database software all Users need to look like this
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(150), unique=True)
    password = db.Column(db.String(150))
    first_name = db.Column(db.String(150))
    notes = db.relationship('Note')     # will be able to access all the notes that the user has created from this Notes field

