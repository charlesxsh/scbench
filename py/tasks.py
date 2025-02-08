import time
from celery import Celery

from errinj.pm import inject_err_to_contract

# Configure Celery to use Redis as the broker
app = Celery('tasks', broker='redis://localhost:6379/0', backend='redis')


@app.task
def process_file(filepath, out):
    inject_err_to_contract(filepath, out)