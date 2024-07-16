from django.contrib import admin
from grocery import models

@admin.register(models.Address)
class AddressAdmin(admin.ModelAdmin):
    list_display = ('id', 'address_text', 'is_primary', 'latitude', 'longitude', 'user', 'created', 'last_updated')
    list_filter = ('user', 'created')
    search_fields = ('address_text', 'user__email')  # Assuming user has an email field

# Registering User model with custom admin options
@admin.register(models.User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('id', 'email', 'first_name','mobile_number', 'last_name', 'is_staff', 'is_delivery_boy', 'is_active', 'date_joined', 'last_login' )
    search_fields = ('email', 'first_name', 'last_name')
    readonly_fields = ('id',)
    
# Registering Category model with custom admin options
@admin.register(models.Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'created', 'last_updated')
    search_fields = ('name',)
    readonly_fields = ('id',)

# Registering Products model with custom admin options
@admin.register(models.Products)
class ProductsAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'category', 'store', 'product_type', 'created', 'last_updated')
    search_fields = ('name', 'category__name')
    readonly_fields = ('id',)

@admin.register(models.UserStore)
class UserStoreAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'user', 'created', 'last_updated')
    search_fields = ('name', 'user')
    readonly_fields = ('id',)

# Registering ProductsImages model with custom admin options
@admin.register(models.ProductsImages)
class ProductsImagesAdmin(admin.ModelAdmin):
    list_display = ('id', 'product', 'created', 'last_updated')
    search_fields = ('product__name',)
    readonly_fields = ('id',)

# Registering ProductPrices model with custom admin options
@admin.register(models.ProductPrices)
class ProductPricesAdmin(admin.ModelAdmin):
    list_display = ('id', 'price', 'discounted_price', 'product', 'weight', 'created', 'last_updated')
    search_fields = ('product__name', 'weight', 'product_type')
    readonly_fields = ('id',)

@admin.register(models.Cart)
class CartAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'product', 'product_prices', 'price', 'discounted_price', 'total_price', 'weight', 'product_type', 'quantity', 'created', 'last_updated')
    list_filter = ('user', 'product')
    search_fields = ('user__email', 'product__name')
    readonly_fields = ('id',)

@admin.register(models.Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'assigned_user', 'payment_method', 'order_status', 'order_value', 'order_count', 'order_charges', 'order_discount', 'address_text', 'delivery_distance', 'latitude', 'longitude',  'created', 'last_updated')
    list_filter = ['order_status']
    search_fields = ['user__email', 'address_text']

@admin.register(models.OrderGrocery)
class OrderGroceryAdmin(admin.ModelAdmin):
    list_display = ('id', 'order', 'product', 'price', 'discounted_price', 'weight', 'product_type', 'quantity', 'product_name', 'total_price', 'created', 'last_updated')
    list_filter = ['product_type']
    search_fields = ['product_name']

@admin.register(models.Policy)
class PolicyAdmin(admin.ModelAdmin):
    list_display = ('id', 'policy', 'created', 'last_updated')

@admin.register(models.AdminDetails)
class AdminDetailsAdmin(admin.ModelAdmin):
    list_display = ('id', 'pickup_number', 'order_support', 'created', 'last_updated')

@admin.register(models.PickupDrop)
class PickupDropAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'pickup', 'drop', 'status', 'created', 'last_updated')
    list_filter = ('status', 'created')
    search_fields = ('pickup', 'drop', 'user__email')