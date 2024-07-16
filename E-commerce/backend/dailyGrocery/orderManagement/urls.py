
from django.urls import path
from orderManagement import views

urlpatterns = [
    path('all/', views.AllAdminOrdersListView.as_view(), name="all_orders"),
    path('check-user/', views.checkUser, name='check_user'),
    path('delivery-orders/', views.AllDeliveryOrdersListView.as_view(), name="delivery_orders"),
    path('update-order/<int:id>/<str:action>/', views.updateOrder, name="update_order"),
]