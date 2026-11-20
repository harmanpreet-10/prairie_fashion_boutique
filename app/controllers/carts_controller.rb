
class CartsController < ApplicationController
  before_action :load_cart, only: [:show]

  def show
    @cart_items = []
    @subtotal = 0

    @cart.each do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      quantity = quantity.to_i
      next if quantity <= 0

      line_total = product.price * quantity

      @cart_items << {
        product: product,
        quantity: quantity,
        line_total: line_total
      }

      @subtotal += line_total
    end
  end

  def add
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i
    quantity = 1 if quantity <= 0

    cart = session[:cart] || {}
    key = product.id.to_s
    current_quantity = cart[key].to_i

    if current_quantity + quantity > product.stock_quantity
      redirect_to product_path(product),
                  alert: "Not enough stock available."
      return
    end

    cart[key] = current_quantity + quantity
    session[:cart] = cart

    redirect_to cart_path,
                notice: "#{product.name} added to your cart."
  end

  def update_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    cart = session[:cart] || {}
    key = product.id.to_s

    unless cart.key?(key)
      redirect_to cart_path, alert: "Product is not in your cart."
      return
    end

    if quantity <= 0
      cart.delete(key)
      flash[:notice] = "Product removed from cart."
    elsif quantity > product.stock_quantity
      redirect_to cart_path,
                  alert: "Only #{product.stock_quantity} items available."
      return
    else
      cart[key] = quantity
      flash[:notice] = "Cart quantity updated."
    end

    session[:cart] = cart
    redirect_to cart_path
  end

  def remove
    cart = session[:cart] || {}
    cart.delete(params[:product_id].to_s)
    session[:cart] = cart

    redirect_to cart_path, notice: "Product removed from cart."
  end

  def clear
    session[:cart] = {}
    redirect_to cart_path, notice: "Shopping cart cleared."
  end

  private

  def load_cart
    @cart = session[:cart] || {}
  end
end
