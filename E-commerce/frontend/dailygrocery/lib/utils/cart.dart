import 'package:dailygrocery/service/product_service.dart';
import 'package:flutter/material.dart';
import 'package:dailygrocery/service/cart_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartFunctionHandler {
  final BuildContext context;
  final CartService cartService;

  CartFunctionHandler({required this.context, required this.cartService});

  // Define a function to handle adding quantity
  Future<bool> addQuantity(
      Product? product, productId, productPricesId, price, discountedPrice, weight) async {
    // Handle the case when product is not provided
    final cartItem = await cartService.findProductInCart(
      productId,
      price,
      discountedPrice ?? 0.0,
    );
    if (product != null) {
      // Handle the case when product is provided
      if (cartItem != null) {
        // Product already exists in the cart
        var qty = cartItem.quantity + 1;
        var total = (qty *
                (discountedPrice != null && discountedPrice != 0.0
                    ? discountedPrice!
                    : price))
            .toDouble();
        total = double.parse(total.toStringAsFixed(2));
        await cartService.updateCartItem(cartItem.id, qty, total);
        Fluttertoast.showToast(
          msg: 'Product quantity updated in cart',
          backgroundColor: Colors.green,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
        );
        return true;
      } else {
        // Product doesn't exist in the cart, add a new entry
        final addedToCart = await cartService.addToCart(
          productId: product.id,
          productName: product.name,
          quantity: 1, // Hardcoded for now, can be dynamic
          price: price,
          productPricesId: productPricesId,
          weight: weight,
          productType: product.productType,
          discountedPrice: discountedPrice ?? 0.0,
        );

        if (addedToCart) {
          Fluttertoast.showToast(
            msg: 'Product added to cart',
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to add product to cart',
            backgroundColor: Colors.red,
            gravity: ToastGravity.CENTER,
            textColor: Colors.white,
          );
        }
        return true;
      }
    } else {
      if (cartItem != null) {
        // Product already exists in the cart
        var qty = cartItem.quantity + 1;
        var total = (qty *
                (discountedPrice != null && discountedPrice != 0.0
                    ? discountedPrice!
                    : price))
            .toDouble();
        total = double.parse(total.toStringAsFixed(2));
        await cartService.updateCartItem(cartItem.id, qty, total);
        Fluttertoast.showToast(
          msg: 'Product quantity updated in cart',
          backgroundColor: Colors.green,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
        );
      }
      return true;
    }
  }

  // Define a function to handle subtracting quantity
  Future<bool> subtractQuantity(productId, price, discountedPrice) async {
    final cartItem = await cartService.findProductInCart(
      productId,
      price,
      discountedPrice ?? 0.0,
    );
    if (cartItem != null && cartItem.quantity > 1) {
      var qty = cartItem.quantity - 1;
      var total = (qty *
              (discountedPrice != null && discountedPrice != 0.0
                  ? discountedPrice!
                  : price))
          .toDouble();
      total = double.parse(total.toStringAsFixed(2));
      await cartService.updateCartItem(cartItem.id, qty, total);
      Fluttertoast.showToast(
        msg: 'Product quantity updated in cart',
        backgroundColor: Colors.green,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
      );
      return true;
    } else {
      // Remove the product from the cart if quantity becomes zero
      await cartService.removeFromCart(cartItem!.id);
      Fluttertoast.showToast(
        msg: 'Product removed from cart',
        backgroundColor: Colors.green,
        gravity: ToastGravity.CENTER,
        textColor: Colors.white,
      );
      return true;
    }
  }
}
