FROM python:3.8 AS builder
LABEL maintainer="Andres Kepler <andres.kepler@entigo.com>"
ARG SRV_PORT=8080
ENV SRV_PORT $SRV_PORT

COPY requirements.txt .
RUN pip install --user  -r requirements.txt

# second unnamed stage
FROM python:3.8-slim

RUN mkdir /code
WORKDIR /code

# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local
COPY run.sh /code/
COPY *.py /code/


# Expose the required Locust ports
EXPOSE 8080

ENV PATH=/root/.local/bin:$PATH

# Start Locust using LOCUS_OPTS environment variable
ENTRYPOINT [ "bash", "./run.sh" ]