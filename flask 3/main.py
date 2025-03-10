# we're going to import this website package, grab that create app function and use that to create an application and run it

from website import create_app  
# we can do this because website is a python package.  whenever you put the __init__.py file in a folder it becomes a python package

app = create_app()

if __name__ == '__main__':
    app.run(debug=True)
    # this will run the flask application, start up a web server 
    # with debug=True, anytime we make a change to our python code, it's going to automatically rerun the web server 
    # turn off debug=True when you're running in production
    # this is on so we don't have to keep manually rerunning the flask web server

