FROM python:latest 

RUN mkdir -p /opt/Code
WORKDIR /opt/Code
COPY requirements.txt .
COPY app.py .
RUN pip3 install -r requirements.txt
RUN python3 -m venv env
RUN . env/bin/activate
ENTRYPOINT flask run --host=0.0.0.0
HEALTHCHECK --interval=30s CMD curl -f http://localhost:5000/ || exit 1
