from . import db   

class Note(db.Model):  
    id = db.Column(db.Integer, primary_key=True) 
    content = db.Column(db.String(1000))  