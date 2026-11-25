
require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @about = Page.find_or_initialize_by(slug: "about-us")
    @about.update!(
      title: "About Us",
      content: "Welcome to Prairie Fashion Boutique."
    )

    @contact = Page.find_or_initialize_by(slug: "contact-us")
    @contact.update!(
      title: "Contact Us",
      content: "Contact our customer service team."
    )
  end

  test "should display about page" do
    get about_url

    assert_response :success
    assert_select "h1", "About Us"
    assert_select ".information-page-content",
                  text: /Welcome to Prairie Fashion Boutique/
  end

  test "should display contact page" do
    get contact_url

    assert_response :success
    assert_select "h1", "Contact Us"
    assert_select ".information-page-content",
                  text: /Contact our customer service team/
  end

  test "should display updated page content" do
    @about.update!(content: "Our updated boutique information.")

    get about_url

    assert_response :success
    assert_select ".information-page-content",
                  text: /Our updated boutique information/
  end

  test "should display informational navigation links" do
    get root_url

    assert_response :success
    assert_select "nav a[href=?]", about_path
    assert_select "nav a[href=?]", contact_path
  end
end
