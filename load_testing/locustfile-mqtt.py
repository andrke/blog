import time
import json
from locust_mqtt import LocustMqttClient
from locust import User, TaskSet, task


class MqttLocust(User):
    min_wait = 5000
    max_wait = 9000

    def __init__(self, *args, **kwargs):
        super(MqttLocust, self).__init__(*args, **kwargs)
        self.client: LocustMqttClient = LocustMqttClient()

        self.client.locust_connect(*self._get_host_and_port())

    def _get_host_and_port(self):
        host = "localhost"
        port = 1883
        host_port = self.host.split(":")
        if len(host_port) == 2:
            host = host_port[0]
            port = int(host_port[1])
        return host, port

    @task
    class ThingBehavior(TaskSet):
        @task
        def publish_with_qos0(self) -> None:
            topic: str = '/echo'
            name: str = 'publish:qos0:{}'.format(topic)
            self.client.publish(topic,
                                payload=json.dumps({'id': '0'}),
                                qos=0,
                                name=name,
                                timeout=10000)

        def on_start(self) -> None:
            time.sleep(5)
