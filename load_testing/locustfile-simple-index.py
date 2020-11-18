from locust import HttpUser, TaskSet, task

class WebsiteUser(HttpUser):
    min_wait = 5000
    max_wait = 9000
    @task
    class UserBehavior(TaskSet):
        @task(1)
        def get_posts(self):
            self.client.get("/")
