class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def foo
    @result = InstaExample.followers_elon
  end
end
