from .mixins import SuperuserRequiredMixin, CustomLoginRequiredMixin, DeliveryUserRequiredMixin
from django.views import generic
from django.contrib.auth.decorators import login_required
from typing import Any, Dict
from django.shortcuts import redirect
from grocery import models


def checkUser(request):
    if request.user.is_superuser:
        return redirect('orderManagement:all_orders')
    else:
        return redirect('orderManagement:delivery_orders')
    
class AllAdminOrdersListView(CustomLoginRequiredMixin, SuperuserRequiredMixin, generic.ListView):
    model = models.Order
    template_name = "allOrders.html"
    context_object_name = 'all_orders'
    paginate_by = 50
    ordering = ['-last_updated','-created']


class AllDeliveryOrdersListView(CustomLoginRequiredMixin, DeliveryUserRequiredMixin, generic.ListView):
    model = models.Order
    template_name = "deliveryOrders.html"
    context_object_name = 'delivery_orders'
    ordering = ['-last_updated','-created']

    def get_queryset(self):
        return super().get_queryset().filter(order_status='placed')

    def get_context_data(self, **kwargs) -> Dict[str, Any]:
        context = super().get_context_data(**kwargs)
        context["accepted_order"] = models.Order.objects.filter(assigned_user=self.request.user)
        return context

@login_required(login_url='/accounts/login/')
def updateOrder(request, id, action):
    try:
        if action == 'assigned':
            models.Order.objects.filter(id=id).update(order_status=action, user=request.user)
        else:
            models.Order.objects.filter(id=id).update(order_status=action)
    except:
        print("order doesn't exists")
    return redirect('orderManagement:delivery_orders')