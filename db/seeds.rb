
# Prairie Fashion Boutique - Database Seeds
# Creates 4 categories and 100 products.
# Safe to run more than once without duplicating products.

categories = {
  "Tops" => "Stylish everyday tops, blouses, and shirts.",
  "Sweaters" => "Comfortable sweaters and knitwear.",
  "Jackets" => "Fashionable jackets and outerwear.",
  "Accessories" => "Handbags, scarves, jewelry, and accessories."
}

categories.each do |name, description|
  category = Category.find_or_initialize_by(name: name)
  category.description = description
  category.save!
end

product_styles = {
  "Tops" => [
    "Classic Cotton T-Shirt",
    "Relaxed Fit Blouse",
    "Ribbed Tank Top",
    "Casual Button-Up Shirt",
    "Long Sleeve Top"
  ],
  "Sweaters" => [
    "Cozy Knit Sweater",
    "Oversized Pullover",
    "Classic Cardigan",
    "Cable Knit Sweater",
    "Turtleneck Sweater"
  ],
  "Jackets" => [
    "Denim Jacket",
    "Lightweight Bomber",
    "Classic Trench Coat",
    "Fleece Zip Jacket",
    "Quilted Jacket"
  ],
  "Accessories" => [
    "Everyday Tote Bag",
    "Soft Winter Scarf",
    "Fashion Bracelet",
    "Crossbody Handbag",
    "Minimalist Necklace"
  ]
}

colors = ["Black", "White", "Blue", "Beige", "Pink"]

product_styles.each do |category_name, styles|
  category = Category.find_by!(name: category_name)

  styles.each_with_index do |style, style_index|
    colors.each_with_index do |color, color_index|
      name = "#{color} #{style}"

      product = Product.find_or_initialize_by(
        name: name,
        category: category
      )

      product.description =
        "Discover our #{name.downcase}, designed for comfort, " \
        "style, and everyday fashion at Prairie Fashion Boutique."

      product.price = (
        14.99 +
        style_index * 8 +
        color_index * 2
      ).round(2)

      product.stock_quantity = 10 + style_index * 5 + color_index

      product.save!
    end
  end
end

# Development admin account
if Rails.env.development?
  admin = AdminUser.find_or_initialize_by(
    email: "admin@example.com"
  )

  if admin.new_record?
    admin.password = "password"
    admin.password_confirmation = "password"
    admin.save!
  end
end

puts "Database seeding completed successfully!"
puts "Categories: #{Category.count}"
puts "Products: #{Product.count}"
puts "Total category/product records: #{Category.count + Product.count}"

# Editable informational pages

Page.find_or_create_by!(slug: "about-us") do |page|
  page.title = "About Us"
  page.content = <<~TEXT
    Welcome to Prairie Fashion Boutique!

    We are a Winnipeg-based fashion boutique dedicated to offering affordable, stylish, and comfortable clothing.

    Our goal is to help customers express their personal style through everyday fashion. Our collection includes tops, bottoms, dresses, and accessories.

    We believe that fashion should be accessible, enjoyable, and suitable for every occasion.

    Thank you for visiting Prairie Fashion Boutique.
  TEXT
end

Page.find_or_create_by!(slug: "contact-us") do |page|
  page.title = "Contact Us"
  page.content = <<~TEXT
    We would love to hear from you!

    If you have questions about our products, orders, or shopping experience, please contact our customer service team.

    Prairie Fashion Boutique
    Winnipeg, Manitoba, Canada

    Thank you for choosing Prairie Fashion Boutique.
  TEXT
end
