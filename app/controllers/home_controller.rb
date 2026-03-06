class HomeController < ApplicationController
  def index
    @frontpage = FrontpageContent.current
  end
end
