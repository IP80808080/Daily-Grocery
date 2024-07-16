from django.db import models
from django.contrib.auth.hashers import make_password
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import AbstractUser
from typing import Any
from django_quill.fields import QuillField

# Local Imports
from .managers import UserManager


PRODUCT_TYPE = (
   ("pouch", "Pouch"),
   ("multipack", "Multipack"),
   (None, None)
)
ORDER_STATUS = (
   ("delivered", "Delivered"),
   ("placed", "Placed"),
   ("assigned", "Assigned"),
   ("picked", "Picked Up"),
   ("cancelled", "Order Cancelled"),
)
PICKUP_DROP_STATUS = (
   ("pending", "Pending"),
   ("cancelled", "Cancelled"),
   ("progress", "In Progress"),
   ("completed", "Completed"),
)
class User(AbstractUser):
   username = None # remove username field, we will use email as unique identifier
   email = models.EmailField(unique=True, null=True, db_index=True)
   mobile_number = models.CharField(_("User Mobile Number"), max_length=50, default="1234567890")
   is_delivery_boy = models.BooleanField(_("Is delivery Boy"), default=False)
   REQUIRED_FIELDS = []
   USERNAME_FIELD = 'email'

   objects = UserManager()
   class Meta:
      verbose_name = _("User")
      verbose_name_plural = _("Users")

   def __str__(self):
      return self.email

   def save(self, *args: Any, **kwargs: Any) -> None:
    """Hash user password if not already."""
    if self.password is not None and not self.password.startswith(
        ("pbkdf2_sha256$", "bcrypt$", "argon2")
    ):
        # If the password is plaintext, identify_hasher returns None
        self.password = make_password(self.password)
    super().save(*args, **kwargs)

    
class UserStore(models.Model):
    name = models.CharField(_("Name"), max_length=250)
    user = models.ForeignKey("User", verbose_name=_("User"), on_delete=models.SET_NULL, null=True)
    created = models.DateTimeField(auto_now_add=True)
    last_updated = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _("User Store")
        verbose_name_plural = _("User Stores")

    def __str__(self):
        return self.name

class Address(models.Model):
   address_text = models.CharField(max_length=1000)
   latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
   longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
   user = models.ForeignKey("User", verbose_name=_("User"), related_name="address_user", on_delete=models.CASCADE)
   is_primary = models.BooleanField(default=False)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Address")
      verbose_name_plural = _("Address")

   def __str__(self):
      return self.address_text
    
class Category(models.Model):
   name = models.CharField(_("Category Name"), max_length=50)
   image = models.ImageField(_("Category image"), upload_to="category-img/", height_field=None)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Category")
      verbose_name_plural = _("Categorys")

   def __str__(self):
      return self.name

class Products(models.Model):
   store = models.ForeignKey("UserStore", verbose_name=_("User Store"), on_delete=models.CASCADE, null=True)
   name = models.CharField(_("Product Name"), max_length=200)
   category = models.ForeignKey("Category", verbose_name=_("Product Category"), on_delete=models.CASCADE)
   details = models.TextField(_("Product Details"))
   product_type = models.CharField(_("Product Type"), choices=PRODUCT_TYPE, default='pouch', max_length=50)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Product")
      verbose_name_plural = _("Products")

   def __str__(self):
      return self.name

class ProductsImages(models.Model):
   image = models.ImageField(_("Product image"), upload_to="product-img/", height_field=None)
   product = models.ForeignKey("Products", related_name="product_image", verbose_name=_("Product"), on_delete=models.CASCADE)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Products Image")
      verbose_name_plural = _("Products Images")

   def __str__(self):
      return str(self.id)

class ProductPrices(models.Model):
   price = models.DecimalField(max_digits=10, decimal_places=2)
   discounted_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
   product = models.ForeignKey("Products", related_name="product_prices", verbose_name=_("Product"), on_delete=models.CASCADE)
   weight = models.CharField(_("Product Weight"), max_length=100)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)
   class Meta:
      verbose_name = _("Product Price")
      verbose_name_plural = _("Product Prices")

   def __str__(self):
      return str(self.id)


class Cart(models.Model):
   user = models.ForeignKey("User", verbose_name=_("user"), related_name="cart_user", null=True, on_delete=models.SET_NULL)
   product = models.ForeignKey("Products", related_name="cart_product", verbose_name=_("Product"), on_delete=models.SET_NULL, null=True)
   product_prices = models.ForeignKey("ProductPrices", verbose_name=_("Cart Product Price"), on_delete=models.SET_NULL, null=True)
   price = models.DecimalField(max_digits=10, decimal_places=2)
   discounted_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
   weight = models.CharField(_("Product Weight"), max_length=100)
   product_type = models.CharField(_("Product Type"), choices=PRODUCT_TYPE, default=None, max_length=50)
   quantity = models.IntegerField(_("Product Quantity"), default=0)
   product_name = models.CharField(_("Product Name"), max_length=200)
   total_price = models.DecimalField(max_digits=10, decimal_places=2)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)
   class Meta:
      verbose_name = _("Cart")
      verbose_name_plural = _("Carts")

   def __str__(self):
      return str(self.price)
   
class Order(models.Model):
   user = models.ForeignKey("User", verbose_name=_("Order User"), related_name="order_user", on_delete=models.CASCADE)
   assigned_user = models.ForeignKey("User", verbose_name=_("Assigned User"), related_name="assigned_user", on_delete=models.CASCADE, blank=True, null=True)
   payment_method = models.CharField(_("Payment Method"), max_length=50, default="cod")
   order_status = models.CharField(_("Order Status"), choices=ORDER_STATUS, default="placed", max_length=100)
   order_value = models.DecimalField(_("Order Value"), max_digits=10, decimal_places=2, default=0.0)
   order_count = models.IntegerField(_("Order Count"), default=0)
   order_charges = models.DecimalField(_("Order Charges"), max_digits=10, decimal_places=2, default=0.0)
   order_discount = models.DecimalField(_("Order Discount"), max_digits=10, decimal_places=2, default=0.0)
   address_text = models.CharField(_("Address Text"), max_length=1000)
   latitude = models.DecimalField(_("Latitude"), max_digits=9, decimal_places=6, null=True, blank=True)
   longitude = models.DecimalField(_("Longitude"), max_digits=9, decimal_places=6, null=True, blank=True)
   is_primary = models.BooleanField(_("Primary Address"), default=False)
   delivery_distance = models.FloatField(_("Delivery Distance in KM"), default=0.0, )
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)
   
   class Meta:
      verbose_name = _("Order")
      verbose_name_plural = _("Order")

   def __str__(self):
      return str(self.order_status)
   
class OrderGrocery(models.Model):
   order = models.ForeignKey("Order", verbose_name=_("Order"), related_name="order", on_delete=models.CASCADE)
   product = models.ForeignKey("Products", related_name="order_product", verbose_name=_("Product"), on_delete=models.CASCADE)
   price = models.DecimalField(_("Product Price"), max_digits=10, decimal_places=2)
   discounted_price = models.DecimalField(_("Discount Price"),max_digits=10, decimal_places=2, null=True, blank=True)
   weight = models.CharField(_("Product Weight"), max_length=100)
   product_type = models.CharField(_("Product Type"), choices=PRODUCT_TYPE, default=None, max_length=50)
   quantity = models.IntegerField(_("Product Quantity"), default=0)
   product_name = models.CharField(_("Product Name"), max_length=200)
   total_price = models.DecimalField(_("Total Price"),max_digits=10, decimal_places=2)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Order Related Grocery")
      verbose_name_plural = _("Order Related Grocerys")

   def __str__(self):
      return str(self.price)


class PickupDrop(models.Model):
   user = models.ForeignKey("User", verbose_name=_("user"), related_name="pickup_drop_user", on_delete=models.CASCADE)
   pickup = models.CharField(_("Pickup Address"), max_length=500)
   drop = models.CharField(_("Drop Address"), max_length=500)
   pickup_latitude = models.DecimalField(_("Pickup Latitude"), max_digits=9, decimal_places=6, null=True, blank=True)
   pickup_longitude = models.DecimalField(_("Pickup Longitude"), max_digits=9, decimal_places=6, null=True, blank=True)
   drop_latitude = models.DecimalField(_("Drop Latitude"), max_digits=9, decimal_places=6, null=True, blank=True)
   drop_longitude = models.DecimalField(_("Drop Longitude"), max_digits=9, decimal_places=6, null=True, blank=True)
   admin_number = models.CharField(_("Admin Mobile Number"), max_length=12, default="8928958148")
   status = models.CharField(_("Status"), choices=PICKUP_DROP_STATUS, max_length=50, default="pending")
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Pickup Drop")
      verbose_name_plural = _("Pickup Drops")

   def __str__(self):
      return str(self.id)
   
class Policy(models.Model):
   policy = QuillField(verbose_name="Policy Content")
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Policy")
      verbose_name_plural = _("Policys")

   def __str__(self):
      return str(self.policy)
   
class TermsofUse(models.Model):
   terms_of_use = QuillField(verbose_name="Terms of use Content")
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Terms of use")
      verbose_name_plural = _("Terms of use")

   def __str__(self):
      return str(self.terms_of_use)


   
class AdminDetails(models.Model):
   pickup_number = models.CharField(_("Pickup Number"), max_length=12)
   order_support = models.CharField(_("Order Support"), max_length=12)
   created = models.DateTimeField(auto_now_add=True)
   last_updated = models.DateTimeField(auto_now=True)

   class Meta:
      verbose_name = _("Admin Detail")
      verbose_name_plural = _("Admin Details")

   def __str__(self):
      return str(self.id)
