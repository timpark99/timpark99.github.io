# https://youtu.be/kng-mJJby8g?si=WrM6xZmSZSxizIq_
# https://www.youtube.com/watch?v=dam0GPOAvVI


from flask import Flask
from views import views

app = Flask(__name__)

app.register_blueprint(views, url_prefix="/views")


if __name__ == '__main__':
    app.run(debug=True, port=8000)
