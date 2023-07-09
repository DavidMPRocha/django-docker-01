from django.db import models
from django.utils import timezone

# Create your models here.
class User(models.Model):
    nome = models.CharField(max_length=50)
    email = models.CharField(max_length=100)
    idade = models.IntegerField()
    create_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return self.nome
    


    