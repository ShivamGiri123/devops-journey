#Base Image
FROM python:3.9-slim

#set working directory
WORKDIR /app

#Copy requirements first (layer catching)
COPY requirements.txt

#Install Dependencies
RUN pip install --no-cache-dir -r requirements.txt

#Copy application code
COPY app.py

#Expose port
EXPOSE 500

#Run application
CMD ["python", "app.py"]
 


