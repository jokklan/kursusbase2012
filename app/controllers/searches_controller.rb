class SearchesController < ApplicationController
  
  def new
    @courses = Course.find_with_index(params[:q])
  end

end
