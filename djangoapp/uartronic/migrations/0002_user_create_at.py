# Generated by Django 4.2.3 on 2023-07-09 14:54

from django.db import migrations, models
import django.utils.timezone


class Migration(migrations.Migration):

    dependencies = [
        ('uartronic', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='create_at',
            field=models.DateTimeField(default=django.utils.timezone.now),
        ),
    ]
