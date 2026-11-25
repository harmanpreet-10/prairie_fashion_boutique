require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = Category.create!(
      name: "Filter Test Fashion",
      description: "Category for advanced filter testing."
    )

    @new_product = Product.create!(
      name: "Filter Test New Shirt",
      description: "Recently created shirt.",
      price: 19.99,
      stock_quantity: 10,
      category: @category,
      created_at: 1.day.ago,
      updated_at: 1.day.ago
    )

    @updated_product = Product.create!(
      name: "Filter Test Updated Shirt",
      description: "Recently updated shirt.",
      price: 29.99,
      stock_quantity: 5,
      category: @category,
      created_at: 10.days.ago,
      updated_at: 1.day.ago
    )

    @old_product = Product.create!(
      name: "Filter Test Old Shirt",
      description: "Older shirt.",
      price: 39.99,
      stock_quantity: 0,
      category: @category,
      created_at: 10.days.ago,
      updated_at: 10.days.ago
    )
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get show" do
    product = products(:one)
    get product_url(product)
    assert_response :success
  end

  test "should filter newly added products" do
    get products_url, params: {
      filter: "new",
      category_id: @category.id
    }

    assert_response :success
    assert_select ".product-card h3",
                  text: @new_product.name
    assert_select ".product-card h3",
                  text: @updated_product.name, count: 0
    assert_select ".product-card h3",
                  text: @old_product.name, count: 0
  end

  test "should filter recently updated products" do
    get products_url, params: {
      filter: "updated",
      category_id: @category.id
    }

    assert_response :success
    assert_select ".product-card h3",
                  text: @updated_product.name
    assert_select ".product-card h3",
                  text: @new_product.name, count: 0
    assert_select ".product-card h3",
                  text: @old_product.name, count: 0
  end

  test "should combine search category stock and collection filters" do
    get products_url, params: {
      search: "Updated Shirt",
      category_id: @category.id,
      availability: "in_stock",
      filter: "updated",
      sort: "price_low"
    }

    assert_response :success
    assert_select ".product-card", count: 1
    assert_select ".product-card h3",
                  text: @updated_product.name
  end

  test "should display all products when collection filter is cleared" do
    get products_url, params: {
      category_id: @category.id,
      filter: "all"
    }

    assert_response :success
    assert_select ".product-card", count: 3
  end

  test "should display empty state when no products match" do
    get products_url, params: {
      search: "Nonexistent Fashion Product",
      category_id: @category.id,
      filter: "new"
    }

    assert_response :success
    assert_select ".empty-state h3",
                  text: "No products found"
  end
end