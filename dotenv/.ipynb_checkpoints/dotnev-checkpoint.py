import os
from dotenv import load_dotenv, dotenv_values

load_dotenv()

print(os.getenv('MY_SECRET_KEY'))


