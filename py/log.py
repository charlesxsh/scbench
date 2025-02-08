import logging
from logging.handlers import RotatingFileHandler
import os

filtered_names = set(["httpx", "httpcore.http11","CryticCompile","asyncio", "openai._base_client"])
def filter_logs(record):
    if record.name in filtered_names:
        return False
    if record.pathname.find("/site-packages/") != -1:
        return False
    return True

# Configure root logging
def setup_logging():
    # Create a logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    # Create handlers for logging to file and console
    file_handler = RotatingFileHandler('console.log')
    console_handler = logging.StreamHandler()

    # Set the logging level for each handler
    file_handler.setLevel(logging.DEBUG)
    console_handler.setLevel(logging.DEBUG)

    # Create a logging format
    formatter = logging.Formatter('%(asctime)s - %(pathname)s:%(lineno)d - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)

    console_handler.addFilter(filter_logs)

    # Add handlers to the logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
def get_private_file_logger(filename:str, level=logging.DEBUG) -> logging.Logger:
    # Create a new logger
    logger = logging.getLogger(os.path.basename(filename).split(".")[0])

    # Set the level of the logger
    logger.setLevel(level)  # Set to whatever level you need

    # Create a handler for the logger
    file_handler = RotatingFileHandler(filename)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(pathname)s:%(lineno)d - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)

    # Add the handler to the logger
    logger.addHandler(file_handler)

    # Disable propagation to the root logger
    logger.propagate = False
    
    return logger
