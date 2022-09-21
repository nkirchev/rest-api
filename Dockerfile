FROM python:3.9
LABEL mainerer="Nikolay Kirchev <nick@kirchev.com>"

ARG TAG

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt \
  && rm requirements.txt

# Install app dependencies
COPY app .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--reload" ]
