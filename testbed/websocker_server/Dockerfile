FROM python:2.7 AS builder
LABEL maintainer="Andres Kepler <andres.kepler@entigo.com>"
ARG FLASK_PORT=8080
ENV FLASK_PORT $FLASK_PORT

COPY requirements.txt .
RUN pip install --user  -r requirements.txt

# second unnamed stage
FROM python:2.7-slim

RUN mkdir /code
WORKDIR /code

# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local
COPY server.py /code/


# Expose the required Locust ports
EXPOSE 8080

ENV PATH=/root/.local/bin:$PATH

# Start Locust using LOCUS_OPTS environment variable
ENTRYPOINT [ "python", "server.py" ]