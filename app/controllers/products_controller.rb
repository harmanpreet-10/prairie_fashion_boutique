class ProductsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @products = Product.includes(:category).with_attached_image

    # Search products by name or description
    if params[:search].present?
      keyword = "%#{Product.sanitize_sql_like(params[:search].strip)}%"

      @products = @products.where(
        "LOWER(products.name) LIKE LOWER(:keyword) OR LOWER(products.description) LIKE LOWER(:keyword)",
        keyword: keyword
      )
    end

    # Filter by category
    if params[:category_id].present?
      @products = @products.where(
        category_id: params[:category_id]
      )
    end

    # Filter by stock availability
    if params[:availability] == "in_stock"
      @products = @products.where("stock_quantity > 0")
    end

    # Filter newly added and recently updated products
    cutoff = 3.days.ago

    case params[:filter]
    when "new"
      @products = @products.where(
        "products.created_at >= ?", cutoff
      )
    when "updated"
      @products = @products.where(
        "products.updated_at >= ? AND products.created_at < ?",
        cutoff, cutoff
      )
    end

    # Sort products
    case params[:sort]
    when "price_low"
      @products = @products.order(price: :asc, id: :asc)
    when "price_high"
      @products = @products.order(price: :desc, id: :asc)
    when "newest"
      @products = @products.order(created_at: :desc, id: :desc)
    else
      @products = @products.order(name: :asc, id: :asc)
    end

    # Pagination: 12 products per page
    @products = @products.page(params[:page]).per(12)
  end

  def show
    @product = Product.includes(:category)
                      .with_attached_image
                      .find(params[:id])
  end
end