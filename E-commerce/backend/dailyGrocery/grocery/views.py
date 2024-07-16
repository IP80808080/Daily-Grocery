from rest_framework import generics, permissions, status
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework.response import Response
from rest_framework.views import APIView
from django.views.generic import TemplateView, View
from grocery import models
from decimal import Decimal
from grocery import serializers


class HomeView(TemplateView):
    template_name = "home.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Retrieve the policy object from the database (adjust the logic as needed)
        categories = models.Category.objects.all() 
        context['categories'] = categories
        return context


class TermsOfView(TemplateView):
    template_name = 'terms-of-use.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Retrieve the policy object from the database (adjust the logic as needed)
        terms_of_use = models.TermsofUse.objects.first() 
        context['terms_of_use'] = terms_of_use
        return context
    

class PolicyView(TemplateView):
    template_name = 'policy.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Retrieve the policy object from the database (adjust the logic as needed)
        policy = models.Policy.objects.first() 
        context['policy'] = policy
        return context


class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = serializers.CustomTokenObtainPairSerializer

class AdminDetailsAPIView(generics.ListAPIView):
    queryset = models.AdminDetails.objects.all()
    serializer_class = serializers.AdminDetailsSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

# ViewSet for Category model, providing read-only actions
class HomeCategoryAPIView(generics.ListAPIView):
    try:
        queryset = models.Category.objects.all().order_by('-created')[:10]
    except:
        queryset = models.Category.objects.all().order_by('-created')

    serializer_class = serializers.CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None


class HomeProductsAPIView(generics.ListAPIView):
    try:
        queryset = models.Products.objects.all().order_by('-created')[:10]
    except:
        queryset = models.Products.objects.all().order_by('-created')

    serializer_class = serializers.ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

class AllCategoryAPIView(generics.ListAPIView):
    queryset = models.Category.objects.all().order_by('-created')
    serializer_class = serializers.CategorySerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None
    
class ProductSearchAPIView(generics.ListAPIView):
    serializer_class = serializers.ProductSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        queryset = models.Products.objects.all()

        # Filter products by category name
        name = self.request.query_params.get('name', None)
        if name:
            queryset = queryset.filter(name__icontains=name).order_by('-created')
        return queryset

class CategoryProductAPIView(generics.ListAPIView):
    serializer_class = serializers.ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        queryset = models.Products.objects.all()

        # Filter products by category name
        name = self.request.query_params.get('name', None)
        if name:
            queryset = queryset.filter(category__name__contains=name).order_by('-created')
        return queryset

class ProductDetailAPIView(generics.RetrieveAPIView):
    queryset = models.Products.objects.all()
    serializer_class = serializers.ProductSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        return Response(serializer.data, status=status.HTTP_200_OK)

# View for creating a user account
class CreateUserAccountView(generics.CreateAPIView):
    queryset = models.User.objects.all()
    serializer_class = serializers.UserAccountSerializer


class CartCreateAPIView(generics.CreateAPIView):
    queryset = models.Cart.objects.all()
    serializer_class = serializers.CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        user = request.user
         # Pass the authenticated user to the serializer context
        serializer = self.get_serializer(data=request.data, context={'user': user})
        serializer.is_valid(raise_exception=True)
        
        # Save the cart object with the authenticated user
        serializer.save(user=user)
        
        # Return the response with the created address data
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
class CartUpdateAPIView(generics.UpdateAPIView):
    queryset = models.Cart.objects.all()
    serializer_class = serializers.CartSingleItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    
class CartItemDeleteView(generics.DestroyAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, *args, **kwargs):
        user = models.User.objects.get(email=self.request.user)
        cart_id = self.kwargs.get('id')
        try:
            cart_item = models.Cart.objects.get(user=user, id=cart_id)
            cart_item.delete()
            return Response({'message': 'Cart item deleted successfully.'}, status=status.HTTP_204_NO_CONTENT)
        except models.Cart.DoesNotExist:
            return Response({'error': 'Cart item not found.'}, status=status.HTTP_404_NOT_FOUND)
        
class FindProductInCartAPIView(generics.RetrieveAPIView):
    queryset = models.Cart.objects.all()
    serializer_class = serializers.CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        user = request.user
        product_id = kwargs.get('productId')
        price = kwargs.get('price')
        discountedPrice = kwargs.get('discountedPrice')
        try:
            cart_item = models.Cart.objects.get(user=user, product=product_id, discounted_price = Decimal(discountedPrice), price=Decimal(price))
            serializer = self.get_serializer(cart_item)
            return Response(serializer.data)
        except models.Cart.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

class GetAllCartAPIView(generics.ListAPIView):
    serializer_class = serializers.CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        # Retrieve the user from the request
        user = models.User.objects.get(email=self.request.user)
        
        # Filter cart items for the current user
        queryset = models.Cart.objects.filter(user=user).order_by('-created')
        
        return queryset

class AddressListView(generics.ListAPIView):

    queryset = models.Address.objects.all()  # Query all addresses
    serializer_class = serializers.AddressSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        # Filter addresses based on the current user
        user = models.User.objects.get(email=self.request.user)
        return models.Address.objects.filter(user=user).order_by('-last_updated')

class SingleAddressAPIView(generics.RetrieveAPIView):
    queryset = models.Address.objects.all()  # Query all addresses
    serializer_class = serializers.AddressSerializer
    permission_classes = [permissions.IsAuthenticated]
 
    def get(self, request, *args, **kwargs):
        # Filter Cart based on the current user
        try:
            id = kwargs.get('id')
            user = models.User.objects.get(email=request.user)
            address = models.Address.objects.get(user=user, id=id)
            serializer = self.get_serializer(address)
            return Response(serializer.data)
        except models.Cart.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        
class AddressIsPrimaryUpdateAPIView(generics.UpdateAPIView):
    queryset = models.Address.objects.all()
    serializer_class = serializers.AddressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        # Update all other addresses for the user to set is_primary to False
        models.Address.objects.filter(user__email=request.user).exclude(id=instance.id).update(is_primary=False)

        return super().update(request, *args, **kwargs)


class OrderUpdateAPIView(generics.UpdateAPIView):
    queryset = models.Order.objects.all()
    serializer_class = serializers.OrderSingleItemSerializer
    permission_classes = [permissions.IsAuthenticated]

class AddressCreateAPIView(generics.CreateAPIView):
    queryset = models.Address.objects.all()
    serializer_class = serializers.AddressSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        # Retrieve the authenticated user from the request
        user = request.user
        # Check if the user has any existing addresses
        has_address = models.Address.objects.filter(user=user).exists()
        
        # If no address is present, set is_primary to True
        if not has_address:
            request.data['is_primary'] = True
         # Pass the authenticated user to the serializer context
        serializer = self.get_serializer(data=request.data, context={'user': user})
        serializer.is_valid(raise_exception=True)
        
        # Save the address object with the authenticated user
        serializer.save(user=user)
        
        # Return the response with the created address data
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
class DeleteAddressAPIView(generics.DestroyAPIView):
    queryset = models.Address.objects.all()
    serializer_class = serializers.AddressSerializer
    permission_classes = [permissions.IsAuthenticated]

class OrderCreateAPIView(generics.CreateAPIView):
    serializer_class = serializers.OrderCreateSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
class OrderListView(generics.ListAPIView):

    queryset = models.Order.objects.all()  # Query all addresses
    serializer_class = serializers.OrderItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        # Filter orders based on the current user
        user = models.User.objects.get(email=self.request.user)
        return models.Order.objects.filter(user=user).order_by('-last_updated')
    
class CartQuantityListView(generics.ListAPIView):
    queryset = models.Cart.objects.all()  # Query all Order
    serializer_class = serializers.CartCountSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        # Filter Cart based on the current user
        user = models.User.objects.get(email=self.request.user)
        return models.Cart.objects.filter(user=user).order_by('-created')

class TotalCartQuantityListView(APIView):
    queryset = models.Cart.objects.all()  # Query all Cart
    serializer_class = serializers.CartItemSerializer
    permission_classes = [permissions.IsAuthenticated]
 
    def get(self, request, format=None):
        
        # Filter Cart based on the current user
        user = models.User.objects.get(email=self.request.user)
        total_items = models.Cart.objects.filter(user=user).count()
        return Response({'total_items': total_items})
    

class CreatePickupDropAPIView(generics.CreateAPIView):
    queryset = models.PickupDrop.objects.all()
    serializer_class = serializers.CreatePickupDropSerializer
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request, *args, **kwargs):
        user = request.user
         # Pass the authenticated user to the serializer context
        serializer = self.get_serializer(data=request.data, context={'user': user})
        serializer.is_valid(raise_exception=True)
        
        # Save the address object with the authenticated user
        serializer.save(user=user)
        
        # Return the response with the created address data
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    

class PickupDropListView(generics.ListAPIView):

    queryset = models.PickupDrop.objects.all()  # Query all PickupDrop
    serializer_class = serializers.PickupDropItemSerializer
    permission_classes = [permissions.IsAuthenticated]
    pagination_class = None

    def get_queryset(self):
        # Filter orders based on the current user
        user = models.User.objects.get(email=self.request.user)
        return models.PickupDrop.objects.filter(user=user).order_by('-created','status')

class CheckCartValidPrices(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        valid = True
        user = models.User.objects.get(email=request.user)
        get_all_carts_items = models.Cart.objects.filter(user=user).order_by('-created')
        for cart_item in get_all_carts_items:
            try:
                product_price = models.ProductPrices.objects.get(id=cart_item.product_prices.id)
                if product_price.discounted_price:
                    if cart_item.price != product_price.price or cart_item.discounted_price != product_price.discounted_price:
                        total_price = Decimal(cart_item.quantity * (product_price.discounted_price if product_price.discounted_price else product_price.price))
                        models.Cart.objects.filter(id=cart_item.id).update(price=product_price.price, discounted_price=product_price.discounted_price, total_price=total_price)
                        valid = False
                elif cart_item.price != product_price.price:
                    total_price = Decimal(cart_item.quantity * product_price.price)
                    models.Cart.objects.filter(id=cart_item.id).update(price=product_price.price, discounted_price=product_price.discounted_price, total_price=total_price)
                    valid = False
                else:
                    valid = True
            except:
                models.Cart.objects.filter(id=cart_item.id).delete()
                valid = False
        return Response({'valid': valid})