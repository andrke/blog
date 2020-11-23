FROM python:3.8 AS builder
MAINTAINER Andres Kepler <andres.kepler@entigo.com>

COPY requirements.txt .
RUN pip install --user  -r requirements.txt

# second unnamed stage
FROM python:3.8-slim

RUN mkdir /locust
RUN apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /locust
# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local
COPY run.sh .
RUN chmod 755 run.sh
COPY *.py /locust/


# Expose the required Locust ports
EXPOSE 5557 5558 8089

ENV PATH=/root/.local/bin:$PATH

# Start Locust using LOCUS_OPTS environment variable
ENTRYPOINT [ "/locust/run.sh" ]