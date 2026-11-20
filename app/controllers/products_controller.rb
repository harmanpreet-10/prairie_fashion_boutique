
class ProductsController < ApplicationController
  def index
    @categories = Category.order(:name)
    @products = Product.includes(:category).order(:name)

    if params[:search].present?
      keyword = "%#{Product.sanitize_sql_like(params[:search].strip)}%"
      @products = @products.where(
        "products.name LIKE :keyword OR products.description LIKE :keyword",
        keyword: keyword
      )
    end

    if params[:category_id].present?
      @products = @products.where(
        category_id: params[:category_id]
      )
    end

    case params[:sort]
    when "price_low"
      @products = @products.reorder(price: :asc)
    when "price_high"
      @products = @products.reorder(price: :desc)
    when "newest"
      @products = @products.reorder(created_at: :desc)
    end
  end

  def show
    @product = Product.includes(:category).find(params[:id])
  end
end
