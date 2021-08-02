FROM python:2.7

COPY requirements.txt /
COPY spoofcheck.py /
COPY libs /
RUN pip install -r requirements.txt

ENTRYPOINT ["python","spoofcheck.py"]
