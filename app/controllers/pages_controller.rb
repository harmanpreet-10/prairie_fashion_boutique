
class PagesController < ApplicationController
  def about
    @page = Page.find_by!(slug: "about-us")
    render :show
  end

  def contact
    @page = Page.find_by!(slug: "contact-us")
    render :show
  end
end
