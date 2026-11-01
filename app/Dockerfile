# FROM python
FROM python:3.12-slim

WORKDIR /app

# COPY ./app/requirements.txt ./app
COPY requirements.txt .

# RUN pip install requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"] 
#ٍExec form
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port 8000 --workers ${WEB_CONCURRENCY:-1}"]
# combine of Exec and shell form       # use Environment Variable Expansion --- yani tedad worker az oon moteghayere moshakhas mishe ---- default == 1

# CMD ["uvicorn", "main:app", "0.0.0.0", "8000"]
# CMD [ "uvicorn main:app --reload" ]
# CMD ["python", "main.py"]