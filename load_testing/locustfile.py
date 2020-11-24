from locust import HttpUser, SequentialTaskSet, task
import feedparser
import uuid
import random

NEWS_FEED_URL = ["https://www.postimees.ee/rss",
                 "https://ilmajaam.postimees.ee/rss",
                 "https://tarbija24.postimees.ee/rss",
                 ]
NEWS_FEED = [x['entries'] for x in list(map(lambda x: feedparser.parse(x), NEWS_FEED_URL))]

NEWS = []
for _feed in NEWS_FEED:
    for feed in _feed:
        title = None
        value = None
        img = None
        content_url = None
        for k, v in feed.items():
            if k == "title":
                title = v
            if k == "summary":
                value = v
            if k == "links":
                content_url = list(filter(lambda x: x['type'] == "text/html", v))[0]['href']
                try:
                    img = list(filter(lambda x: x['type'] == "image/jpeg", v))[0]['href']
                except IndexError:
                    img = "NoImage"

            if title and value and img and content_url:
                data = dict(title=title, content=value, img_url=img, content_url=content_url)
                NEWS.append(data)


class WebsiteUser(HttpUser):
    min_wait = 5000
    max_wait = 9000
    @task
    class UserBehavior(SequentialTaskSet):
        def on_start(self):
            """ on_start is called when a Locust start before
                any task is scheduled
            """
            self.login()

        def register(self):
            uid = str(uuid.uuid4())
            user = uid.split("-")[0]
            email = "{}@{}.local".format(user, uid.split("-")[1])
            password = user
            return dict(user=user, password=password, email=email, return_data=self.client.post("/api/auth/register",
                                                                                                json=dict(username=user,
                                                                                                     password=password,
                                                                                                     email=email)))

        def login(self):
            register_data = self.register()
            with self.client.post("/api/auth/login",
                             {"username": register_data.get("user"),
                              "password": register_data.get("password")}) as response:
                self.token = response.json().get('token')

        @task(6)
        def get_sleep_time(self):
            sleep = 20
            self.client.get("/sleep/?time={}".format(sleep), timeout=None)

        @task(5)
        def get_nginx_health(self):
            self.client.get("/health/health.html")

        @task(4)
        def get_full_stack_healthz(self):
            self.client.get("/healthz/")

        @task(3)
        def get_first_three_pages(self):
            for i in [100, 200, 300]:
                self.client.get("/api/posts/?limit=100&offset={}".format(i))

        @task(2)
        def post_posts(self):
            self.res = self.client.post("/api/posts/",
                            json=random.choice(NEWS),
                            headers={
                                 "Authorization": 'Token {}'.format(self.token)
                            }
                            )
        @task(1)
        def get_posts(self):
            self.client.get("/")

