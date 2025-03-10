# this will store all the main views or the URL endpoints for the front end of our website
# where users can actually go to

from flask import Blueprint, render_template

views = Blueprint('views', __name__)

@views.route('/')
def home():
    return render_template("home.html")