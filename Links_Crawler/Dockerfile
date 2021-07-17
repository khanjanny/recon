FROM python:3.6

RUN pip3 install nyawc --no-cache-dir
COPY Links_Crawler.py /usr/bin/Links_Crawler.py 
RUN chmod a+x /usr/bin/Links_Crawler.py 


ENTRYPOINT ["python3","/usr/bin/Links_Crawler.py"]
