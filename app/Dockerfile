FROM python:3.11-alpine3.22

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000/tcp

ENTRYPOINT [ "python3" ]

CMD [ "main.py" ]