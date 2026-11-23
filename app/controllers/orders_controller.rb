
class OrdersController < ApplicationController
  class CheckoutError < StandardError; end

  before_action :load_cart_items, only: %i[new create]

  def new
    if @cart_items.empty?
      redirect_to cart_path, alert: "Your shopping cart is empty."
      return
    end

    @order = Order.new(province: "MB")
    calculate_totals
  end

  def create
    if @cart_items.empty?
      redirect_to cart_path, alert: "Your shopping cart is empty."
      return
    end

    @order = Order.new(order_params)
    calculate_totals

    unless @order.valid?
      render :new, status: :unprocessable_entity
      return
    end

    begin
      Order.transaction do
        locked_items = @cart_items.sort_by do |item|
          item[:product].id
        end.map do |item|
          product = Product.lock.find(item[:product].id)
          quantity = item[:quantity]

          if quantity > product.stock_quantity
            raise CheckoutError,
                  "Not enough stock available for #{product.name}."
          end

          { product: product, quantity: quantity }
        end

        @subtotal = locked_items.sum do |item|
          item[:product].price * item[:quantity]
        end

        calculate_totals
        @order.save!

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

      session[:cart] = {}

      redirect_to order_path(@order),
                  notice: "Your order was placed successfully!"

    rescue CheckoutError,
           ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotFound => e

      flash.now[:alert] = "Checkout failed: #{e.message}"
      load_cart_items
      calculate_totals
      render :new, status: :unprocessable_entity
    end
  end

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
      :shipping_address,
      :province
    )
  end

  def calculate_totals
    @order.subtotal = @subtotal
    @order.gst_amount = 0
    @order.pst_amount = 0
    @order.hst_amount = 0
    @order.total = @subtotal

    return unless CanadianSalesTax::RATES.key?(@order.province)

    tax = CanadianSalesTax.new(
      subtotal: @subtotal,
      province: @order.province
    )

    @order.gst_amount = tax.gst_amount
    @order.pst_amount = tax.pst_amount
    @order.hst_amount = tax.hst_amount
    @order.total = tax.total
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
