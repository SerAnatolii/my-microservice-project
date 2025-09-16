FROM python:3.9-slim

WORKDIR /app

COPY django_app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY django_app .

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "myproject.wsgi:application"]