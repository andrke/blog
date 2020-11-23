##How to execute

### Dockerized setup
`$ docker build . -t locust-tasks`

`$ docker run -it --rm -p=8089:8089 locust-tasks:latest -t https://example.com -l locustfile-simple-index.py`

#### Headless 

##### Simple index

`docker run -it --rm entigoandrke/locust-tasks:latest \
  -t https://postimees.ee -l locustfile-simple-index.py -e '--headless -u 100 -r 10'`


##### Testbed testing
Without locustfile specification default is locustfile.py

`docker run -it --rm entigoandrke/locust-tasks:latest \
  -t https://<TESTBED_IP_ADDRESS> '--headless -u 100 -r 10'`


### Virtual env

`$python3 -m venv .venv`

`$activate .evn/bin/active`

`$pip install -r requirements.txt`

`$./run.sh`

## Distributed setup

Follow the [Kubernetes](./kubernetes) instructions
