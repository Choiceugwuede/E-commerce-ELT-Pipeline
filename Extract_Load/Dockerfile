FROM python:3.10-slim

WORKDIR /Extractor

COPY ./requirements.txt /Extractor
RUN pip install --no-cache-dir -r /Extractor/requirements.txt

COPY ./extract_load.py /Extractor

RUN mkdir -p /logs

CMD ["python", "extract_load.py"]
