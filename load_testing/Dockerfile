FROM python:3.8 AS builder
MAINTAINER Andres Kepler <andres.kepler@entigo.com>

COPY requirements.txt .
RUN pip install --user  -r requirements.txt

# second unnamed stage
FROM python:3.8-slim

RUN mkdir /locust-tasks
WORKDIR /locust-tasks
# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local
COPY . .
RUN chmod 755 run.sh


# Expose the required Locust ports
EXPOSE 5557 5558 8089

ENV PATH=/root/.local/bin:$PATH

# Start Locust using LOCUS_OPTS environment variable
ENTRYPOINT [ "/locust-tasks/run.sh" ]