from rest_framework import serializers
from . import models


class PostSerializer(serializers.ModelSerializer):

    class Meta:
        fields = ('id', 'title', 'content', 'img_url', 'content_url', 'created_at', 'updated_at',)
        model = models.Post
