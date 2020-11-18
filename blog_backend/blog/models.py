from django.db import models


class Post(models.Model):
    title = models.CharField(max_length=150)
    content = models.TextField()
    img_url = models.URLField(max_length=150, default="img/Missing-image-232x150.png")
    content_url = models.URLField(max_length=150, default="index.html")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title
