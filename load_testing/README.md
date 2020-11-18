##How to execute

### Dockerized setup
`$ docker build . -t locust-tasks`

`$ docker network create --driver bridge locustnw`

`$ docker run -it --rm -p=8089:8089 \
  -e "TARGET_HOST=http://exampleserver:8080" \
   --network=locustnw locust-tasks:latest`

### Virtual env

`$python3 -m venv .venv`

`$activate .evn/bin/active`

`$pip install -r requirements.txt`

`$./run.sh`

## Distributed setup

https://blog.realkinetic.com/load-testing-with-locust-part-2-5f5abd8dbce4