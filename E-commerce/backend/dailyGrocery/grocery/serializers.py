from decimal import Decimal
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.db.models import Sum
from grocery import models

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    email = serializers.EmailField(source='user.email')
    full_name = serializers.CharField(source='user.get_full_name', read_only=True)

    def validate(self, attrs):
        data = super().validate(attrs)
        refresh = self.get_token(self.user)
        data['refresh'] = str(refresh)
        data['access'] = str(refresh.access_token)
        data['email'] = self.user.email
        data['full_name'] = self.user.get_full_name()
        data['mobile_number'] = self.user.mobile_number
        return data

    class Meta:
        model = models.User
        fields = ('email', 'full_name')


# Serializer for Category model
class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Category
        # Fields to include in the serialized representation
        fields = ['id', 'name', 'image']
        
# Serializer for ProductPrices model
class ProductPricesSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.ProductPrices
        # Fields to include in the serialized representation
        fields = ['id', 'price', 'discounted_price', 'weight']
        
# Serializer for ProductsImages model
class ProductsImagesSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.ProductsImages
        # Fields to include in the serialized representation
        fields = ['id', 'image']
        
# Serializer for Products model
class ProductSerializer(serializers.ModelSerializer):
    # Nested serializers for related models
    product_image = ProductsImagesSerializer(many=True, read_only=True)
    product_prices = ProductPricesSerializer(many=True, read_only=True)

    class Meta:
        model = models.Products
        # Including fields from the Products model and the nested serializers
        fields = '__all__'
        
    
# Serializer for User model
class UserAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.User
        # Fields to include in the serialized representation
        fields = ['email', 'password', 'first_name', 'last_name', 'mobile_number']
        # Extra keyword arguments for customization, e.g., write-only password field
        extra_kwargs = {'password': {'write_only': True}}
        

    def create(self, validated_data):
        # Custom create method to create a user using the custom manager
        user = models.User.objects.create_user(**validated_data)
        return user

class CartItemSerializer(serializers.ModelSerializer):
    user = serializers.CharField(source='user.id', read_only=True)

    class Meta:
        model = models.Cart
        fields =  '__all__'
        
class CartSingleItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Cart
        fields =  ['quantity', 'total_price', 'discounted_price']

class AdminDetailsSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.AdminDetails
        fields =  ['id', 'pickup_number', 'order_support']
 
class AddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Address
        fields = ['id', 'address_text', 'latitude', 'longitude', 'is_primary']
        
class OrderCreateSerializer(serializers.Serializer):
    address_id = serializers.IntegerField()  # Field to receive the address ID from the frontend
    payment_method = serializers.CharField(max_length=100)  # Field to receive the payment method from the frontend
    distance = serializers.FloatField()

    def create(self, validated_data):
        # Get the address ID and payment method from the validated data
        address_id = validated_data.get('address_id', None)
        payment_method = validated_data.get('payment_method', 'COD')
        distance = validated_data.get('distance', 0.0)
         # Get the user from the context
        user = self.context['request'].user

        # Get the address object corresponding to the provided address ID
        try:
            address = models.Address.objects.get(id=address_id)
        except  models.Address.DoesNotExist:
            raise serializers.ValidationError("Invalid address ID")

        # Get the cart items for the current user
        user = self.context['request'].user
        cart_items =  models.Cart.objects.filter(user=user)

        # Calculate total order value and discount from cart_items
        total_order_value = cart_items.aggregate(total_order_value=Sum('total_price'))['total_order_value'] or 0.0
        total_order_price = cart_items.aggregate(total_order_price=Sum('price'))['total_order_price'] or 0.0
        overallDiscount = 0
        for item in cart_items:
            if item.discounted_price:
                overallDiscount += (item.price - item.discounted_price) * item.quantity

        # get order value charges
        deliveryCharge = 0;
        if distance <= 3:
            deliveryCharge = 20;
        elif (distance > 3 and distance <= 5):
            deliveryCharge = 25;
        else:
            deliveryCharge = 25 + (distance - 5) * 5;
        # Create the order for each cart item
        order = models.Order.objects.create(
            user=user,
            payment_method=payment_method,
            address_text=address.address_text,
            latitude=address.latitude,
            longitude=address.longitude,
            is_primary=address.is_primary,
            order_value=total_order_value + Decimal(deliveryCharge),
            order_charges=Decimal(deliveryCharge),
            order_count=len(cart_items) or 0,
            order_discount= 0 if overallDiscount < 0 else overallDiscount,
            delivery_distance = distance
        )
        for cart_item in cart_items:
            models.OrderGrocery.objects.create(
                order=order,
                product=cart_item.product,
                price=cart_item.price,
                discounted_price=cart_item.discounted_price,
                weight=cart_item.weight,
                product_type=cart_item.product_type,
                quantity=cart_item.quantity,
                product_name=cart_item.product.name,
                total_price=cart_item.total_price,
            )

        # Delete the cart items once the order is created
        cart_items.delete()
        return validated_data

class OrderSingleItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Order
        fields =  ['order_status']

class OrderGrocerySerializer(serializers.ModelSerializer):
    class Meta:
        model = models.OrderGrocery
        fields = '__all__'
        
class OrderItemSerializer(serializers.ModelSerializer):
    order_status = serializers.CharField(source='get_order_status_display', read_only=True)
    order_groceries = OrderGrocerySerializer(source='order', many=True, read_only=True)

    class Meta:
        model = models.Order
        fields = '__all__'

class CartCountSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Cart
        fields = ['product', 'price', 'discounted_price', 'quantity']
        

class CreatePickupDropSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.PickupDrop
        # Fields to include in the serialized representation
        fields = ['pickup', 'drop', ]



class PickupDropItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.PickupDrop
        fields = ['id', 'pickup', 'drop', 'admin_number', 'status']
