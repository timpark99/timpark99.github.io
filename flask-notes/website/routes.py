from flask import Blueprint, render_template, request, redirect
from .models import Note
from . import db

routes = Blueprint('routes', __name__)

@routes.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':    
        note_content = request.form.get('note')
        new_note = Note(content=note_content) 
        db.session.add(new_note)
        db.session.commit() 
        return redirect('/')
    
    all_notes = Note.query.all()
    return render_template('home.html', notes=all_notes)

@routes.route('/delete-note/<int:id>')  
def delete_note(id):
    note = Note.query.get(id)
    db.session.delete(note)
    db.session.commit()  
    return redirect('/')  
