
require "test_helper"

class PageTest < ActiveSupport::TestCase
  setup do
    @page = Page.new(
      title: "Test Page",
      slug: "test-page",
      content: "This is a test page."
    )
  end

  test "page is valid with required attributes" do
    assert @page.valid?
  end

  test "page requires a title" do
    @page.title = nil
    assert_not @page.valid?
  end

  test "page requires content" do
    @page.content = nil
    assert_not @page.valid?
  end

  test "page requires a slug" do
    @page.slug = nil
    assert_not @page.valid?
  end

  test "page requires a unique slug" do
    @page.save!

    duplicate = @page.dup

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "page rejects invalid slug format" do
    @page.slug = "Invalid Page URL"

    assert_not @page.valid?
  end
end
