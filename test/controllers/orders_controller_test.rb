
require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to cart when checkout is empty" do
    get new_order_url

    assert_redirected_to cart_path
  end

  test "should get show" do
    order = orders(:one)

    get order_url(order)

    assert_response :success
  end
end
