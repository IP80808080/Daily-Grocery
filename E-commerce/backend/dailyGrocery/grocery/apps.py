from django.apps import AppConfig


class GroceryConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'grocery'

    def ready(self) -> None:
        from . import signal
        return super().ready()
