from django.contrib.auth.mixins import UserPassesTestMixin, LoginRequiredMixin
from django.http import HttpResponseRedirect
from django.urls import reverse

class SuperuserRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        return self.request.user.is_superuser

class DeliveryUserRequiredMixin(UserPassesTestMixin):
    def test_func(self):
        return self.request.user.is_delivery_boy

class CustomLoginRequiredMixin(LoginRequiredMixin):
    def dispatch(self, request, *args, **kwargs):
        if not request.user.is_authenticated:
            # If the user is not authenticated, redirect to the login page
            return HttpResponseRedirect(reverse('login'))
        return super().dispatch(request, *args, **kwargs)
