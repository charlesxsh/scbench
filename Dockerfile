# Use an official Python runtime as a parent image
FROM python:3.12

# Set the working directory in the container
WORKDIR /scbench

# Copy the current directory contents into the container at /scbench
COPY requirements.txt /scbench/

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt