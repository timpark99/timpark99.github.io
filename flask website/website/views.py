# this will store all the main views or the URL endpoints for the front end of our website
# where users can actually go to

from flask import Blueprint, render_template, request, flash, jsonify
from flask_login import login_required, current_user        # current_user is used to detect whether a user is logged in or not
from .models import Note
from . import db
import json

views = Blueprint('views', __name__)

@views.route('/', methods=['GET', 'POST'])      # ensure post method is allowed for this route
@login_required       # you cannot get to the home page unless you login
def home():
    if request.method == 'POST':
        note = request.form.get('note')

        if len(note) < 1:
            flash('Note is too short!', category='error')
        else:
            new_note = Note(data=note, user_id=current_user.id)
            db.session.add(new_note)
            db.session.commit()
            flash('Note added!', category='success')
    return render_template("home.html", user=current_user)      # we will be able to reference this current user and check if it's authenticated

@views.route('/delete-note', methods=['POST'])
def delete_note():
    note = json.loads(request.data)     # takes in data from a post request
    noteId = note['noteId']     # access the noteId attribute from index.js
    note = Note.query.get(noteId)
    if note:
        if note.user_id == current_user.id:
            db.session.delete(note)
            db.session.commit()
            
    return jsonify({})