# Use an official Python base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Create a non-root user and give ownership of the /app directory
RUN useradd --create-home appuser && chown -R appuser /app

# Copy the application code to the container
COPY app/ .

# Install any needed packages specified in requirements.txt and remove unnecessary files
RUN pip install --no-cache-dir --trusted-host pypi.python.org -r requirements.txt && \
    rm poetry.lock pyproject.toml requirements.txt

# Expose the port that the app will run on
EXPOSE 8080

# Switch to the non-root user
USER appuser

# Define the command to start the application using Gunicorn
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8080", "th3-server:app"]
