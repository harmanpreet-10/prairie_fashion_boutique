
class OrdersController < ApplicationController
  class CheckoutError < StandardError; end

  before_action :load_cart_items, only: [:new, :create]

  # GET /checkout
  def new
    @order = Order.new

    if @cart_items.empty?
      redirect_to cart_path,
                  alert: "Your shopping cart is empty."
      return
    end

    @order.total = @subtotal
  end

  # POST /orders
  def create
    @order = Order.new(order_params)

    if @cart_items.empty?
      redirect_to cart_path,
                  alert: "Your shopping cart is empty."
      return
    end

    # FIX: Calculate total BEFORE validating the order.
    @order.total = @subtotal

    unless @order.valid?
      render :new, status: :unprocessable_entity
      return
    end

    begin
      Order.transaction do
        # Lock products in a consistent order.
        locked_items = @cart_items.sort_by do |item|
          item[:product].id
        end.map do |item|
          product = Product.lock.find(item[:product].id)
          quantity = item[:quantity]

          if quantity > product.stock_quantity
            raise CheckoutError,
                  "Not enough stock available for #{product.name}."
          end

          {
            product: product,
            quantity: quantity
          }
        end

        # Recalculate total using current product prices.
        @order.total = locked_items.sum do |item|
          item[:product].price * item[:quantity]
        end

        # Save the order.
        @order.save!

        # Save order items and reduce product stock.
        locked_items.each do |item|
          product = item[:product]
          quantity = item[:quantity]

          @order.order_items.create!(
            product: product,
            quantity: quantity,
            unit_price: product.price
          )

          product.update!(
            stock_quantity: product.stock_quantity - quantity
          )
        end
      end

      # Clear cart only after successful order creation.
      session[:cart] = {}

      redirect_to order_path(@order),
                  notice: "Your order was placed successfully!"

    rescue CheckoutError,
           ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e

      flash.now[:alert] = "Checkout failed: #{e.message}"

      load_cart_items
      @order.total = @subtotal

      render :new, status: :unprocessable_entity
    end
  end

  # GET /orders/:id
  def show
    @order = Order.includes(
      order_items: :product
    ).find(params[:id])
  end

  private

  def order_params
    params.require(:order).permit(
      :customer_name,
      :email,
      :shipping_address
    )
  end

  def load_cart_items
    @cart_items = (session[:cart] || {}).filter_map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product

      quantity = quantity.to_i
      next if quantity <= 0

      {
        product: product,
        quantity: quantity,
        line_total: product.price * quantity
      }
    end

    @subtotal = @cart_items.sum do |item|
      item[:line_total]
    end
  end
end
