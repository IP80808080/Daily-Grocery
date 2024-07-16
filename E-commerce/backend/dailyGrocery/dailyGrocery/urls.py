
from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView
)
from django.conf import settings
from django.conf.urls.static import static
from grocery import views
from orderManagement import views as managemanet_views


router = routers.DefaultRouter()

urlpatterns = [
    path('admin/', admin.site.urls),
    path('rest/', include(router.urls)),
    path('accounts/', include('django.contrib.auth.urls')),
    path('orders/', include(('orderManagement.urls', 'orderManagement'), namespace='orderManagement')),
    # Default URL
    path('', views.HomeView.as_view(), name='home'),
    path('terms-of-use/', views.TermsOfView.as_view(), name="terms_of_use"),
    path('policy/', views.PolicyView.as_view(), name='policy'),
    # Auth and User APIs
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
    path('api/token/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('create-account/', views.CreateUserAccountView.as_view(), name='create_account'),
    path('user-address/', views.AddressListView.as_view(), name="address_list"),
    path('is-primary/<int:pk>/', views.AddressIsPrimaryUpdateAPIView.as_view(), name='update_primary_address'),
    path('save-address/', views.AddressCreateAPIView.as_view(), name='create_address'),
    path('delete-address/<int:pk>/', views.DeleteAddressAPIView.as_view(), name='delete_address'),
    path('single-address/<int:id>/', views.SingleAddressAPIView.as_view(), name='single-address'),
    path('admin-details/', views.AdminDetailsAPIView.as_view(), name='admin_details'),
    # Product APIs
    path('product/<int:pk>/', views.ProductDetailAPIView.as_view(), name="single_product"),
    path('search-products/', views.ProductSearchAPIView.as_view(), name='product_search'),
    path('home-page-products/', views.HomeProductsAPIView.as_view(), name='home_page_products'),
    # Category APIs
    path('category-product/', views.CategoryProductAPIView.as_view(), name='category_product'),
    path('home-page-categories/', views.HomeCategoryAPIView.as_view(), name='home_page_category'),
    path('all-categories/', views.AllCategoryAPIView.as_view(), name='all_categories'),
    # Cart APIs
    path('cart/', views.GetAllCartAPIView.as_view(), name="cart"),
    path('cart-quantity/', views.CartQuantityListView.as_view(), name="cart_quantity"),
    path('add-to-cart/', views.CartCreateAPIView.as_view(), name="add_to_cart"),
    path('cart-item/<int:id>/delete/', views.CartItemDeleteView.as_view(), name='cart_item-delete'),
    path('update-to-cart/<int:pk>/<int:quantity>/', views.CartUpdateAPIView.as_view(), name="update_to_cart"),
    path('cart/product-exists/<int:productId>/<str:price>/<str:discountedPrice>/', views.FindProductInCartAPIView.as_view(), name="product_cart_exists"),
    path('total-cart-items/', views.TotalCartQuantityListView.as_view(), name='total_cart_items'),
    path('check-valid-cart-prices/', views.CheckCartValidPrices.as_view(), name='check_valid_cart_prices'),
    # Orders APIs
    path('place-order/', views.OrderCreateAPIView.as_view(), name='place_order'),
    path('update-order/<int:pk>/', views.OrderUpdateAPIView.as_view(), name='update_order'),
    path('orders/', views.OrderListView.as_view(), name="orders"),
    # PickupDrop APIs
    path('create-pick-drop/', views.CreatePickupDropAPIView.as_view(), name="create_pickup_drop"),
    path('pick-drop-list/', views.PickupDropListView.as_view(), name="pickup_drop_list"),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT) + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)   