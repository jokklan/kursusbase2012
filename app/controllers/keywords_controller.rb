class KeywordsController < ApplicationController
  def index
    @keywords = Keyword.all
  end

  def show
    @keyword = Keyword.find(params[:id])
  end

  def new
    @keyword = Keyword.new
  end

  def edit
    @keyword = Keyword.find(params[:id])
  end

  def create
    @keyword = Keyword.new(params[:keyword])
    if @keyword.save
      redirect_to @keyword, notice: 'Keyword was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @keyword = Keyword.find(params[:id])
    if @keyword.update_attributes(params[:keyword])
      redirect_to @keyword, notice: 'Keyword was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @keyword = Keyword.find(params[:id])
    @keyword.destroy
  end
end
