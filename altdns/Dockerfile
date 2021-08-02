FROM python:2.7

RUN pip install py-altdns --no-cache-dir
RUN ls /home
COPY requirements.txt /
COPY words.txt /
RUN pip install -r requirements.txt

ENTRYPOINT ["altdns"]
