
require "test_helper"
require "stringio"
require "mini_magick"

class ProductTest < ActiveSupport::TestCase
  setup do
    @category = Category.create!(
      name: "Image Test Category",
      description: "Category used for product image testing"
    )

    @product = Product.create!(
      name: "Test Cotton Shirt",
      description: "Product used for image testing",
      price: 29.99,
      stock_quantity: 10,
      category: @category
    )
  end

  test "product is valid without an image" do
    assert @product.valid?
    assert_not @product.image.attached?
  end

  test "product accepts a valid PNG image" do
    attach_test_image

    assert @product.image.attached?
    assert @product.valid?
    assert_equal "image/png", @product.image.blob.content_type
  end

  test "product rejects unsupported image formats" do
    @product.image.attach(
      io: StringIO.new("Invalid image content"),
      filename: "invalid.txt",
      content_type: "text/plain"
    )

    assert_not @product.valid?
    assert_includes @product.errors[:image],
                    "must be a JPEG, PNG, or WebP image"
  end

  test "product rejects images larger than 5 MB" do
    @product.image.attach(
      io: StringIO.new("a" * (5.megabytes + 1)),
      filename: "large.png",
      content_type: "image/png",
      identify: false
    )

    assert_not @product.valid?
    assert_includes @product.errors[:image],
                    "must not exceed 5 MB"
  end

  test "product generates a 300 by 300 thumbnail" do
    attach_test_image

    variant = @product.image.variant(:thumbnail).processed
    image = MiniMagick::Image.read(variant.download)

    assert_equal 300, image.width
    assert_equal 300, image.height
  end

  test "product generates a medium image within 600 pixels" do
    attach_test_image

    variant = @product.image.variant(:medium).processed
    image = MiniMagick::Image.read(variant.download)

    assert_operator image.width, :<=, 600
    assert_operator image.height, :<=, 600
  end

  test "product generates a large image within 1000 pixels" do
    attach_test_image

    variant = @product.image.variant(:large).processed
    image = MiniMagick::Image.read(variant.download)

    assert_operator image.width, :<=, 1000
    assert_operator image.height, :<=, 1000
  end

  private

  def attach_test_image
    image_data = MiniMagick.convert do |command|
      command.size "1200x1200"
      command << "xc:white"
      command << "png:-"
    end

    @product.image.attach(
      io: StringIO.new(image_data),
      filename: "test-product.png",
      content_type: "image/png"
    )
  end
end
