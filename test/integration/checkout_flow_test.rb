
require "test_helper"

class CheckoutFlowTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(
      name: "Test Fashion Category",
      description: "Products used for checkout testing"
    )

    @product = Product.create!(
      name: "Test Fashion Sweater",
      description: "Sweater used for checkout testing",
      price: 100.00,
      stock_quantity: 10,
      category: @category
    )
  end

  test "checkout page displays customer information and province selection" do
    post add_cart_path, params: {
      product_id: @product.id,
      quantity: 1
    }

    get checkout_path

    assert_response :success
    assert_select "form"
    assert_select "select[name='order[province]']"
  end

  test "successful checkout saves order and reduces stock" do
    post add_cart_path, params: {
      product_id: @product.id,
      quantity: 2
    }

    assert_difference "Order.count", 1 do
      assert_difference "OrderItem.count", 1 do
        post orders_path, params: {
          order: {
            customer_name: "Test Customer",
            email: "test@example.com",
            shipping_address: "123 Test Street, Winnipeg",
            province: "MB"
          }
        }
      end
    end

    order = Order.order(:id).last

    assert_redirected_to order_path(order)
    assert_equal "MB", order.province
    assert_equal BigDecimal("200.00"), order.subtotal
    assert_equal BigDecimal("10.00"), order.gst_amount
    assert_equal BigDecimal("14.00"), order.pst_amount
    assert_equal BigDecimal("224.00"), order.total

    assert_equal 2, order.order_items.first.quantity
    assert_equal 8, @product.reload.stock_quantity

    get cart_path
    assert_response :success
    assert_select "a", text: /Checkout/, count: 0
  end

  test "Nova Scotia checkout applies HST" do
    post add_cart_path, params: {
      product_id: @product.id,
      quantity: 1
    }

    post orders_path, params: {
      order: {
        customer_name: "Test Customer",
        email: "test@example.com",
        shipping_address: "123 Test Street, Halifax",
        province: "NS"
      }
    }

    order = Order.order(:id).last

    assert_equal "NS", order.province
    assert_equal BigDecimal("0"), order.gst_amount
    assert_equal BigDecimal("0"), order.pst_amount
    assert_equal BigDecimal("14.00"), order.hst_amount
    assert_equal BigDecimal("114.00"), order.total
  end

  test "invalid checkout does not create an order" do
    post add_cart_path, params: {
      product_id: @product.id,
      quantity: 1
    }

    assert_no_difference "Order.count" do
      post orders_path, params: {
        order: {
          customer_name: "",
          email: "invalid-email",
          shipping_address: "",
          province: "MB"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal 10, @product.reload.stock_quantity
  end

  test "checkout prevents purchases exceeding available stock" do
    post add_cart_path, params: {
      product_id: @product.id,
      quantity: 2
    }

    @product.update!(stock_quantity: 1)

    assert_no_difference "Order.count" do
      post orders_path, params: {
        order: {
          customer_name: "Test Customer",
          email: "test@example.com",
          shipping_address: "123 Test Street",
          province: "MB"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal 1, @product.reload.stock_quantity
  end
end
