class DishesController < ApplicationController

	def show
		@experience = Experience.find(params[:experience_id])
		@dish = Dish.find(params[:id])
	end

	def new
		@experience = Experience.find(params[:experience_id])
		@dish = Dish.new
	end

	def create
    @venue = Venue.create_venue(params[:place_id])
		@experience = Experience.find(params[:experience_id])
		@dish = @experience.dishes.build(dish_params)
		@dish.venue = @venue
		if @venue.save && @dish.save
			redirect_to experiences_path
		else
			render :new
		end
	end

  def edit
    @dish = Dish.find_by(id: params[:id])
    @experience = @dish.experience
  end

  def update
    @dish = Dish.find_by(id: params[:id])
    @experience = @dish.experience
    if params[:place_id] != ""
      @venue = Venue.create_venue(params[:place_id])
      @dish.venue = @venue
    end
    @dish.update_attributes(dish_params)
    if @dish.save
      redirect_to experiences_path
    else
      render :edit
    end
  end

  def destroy
    @dish = Dish.find_by(id: params[:id])
    @dish.destroy
    redirect_to experiences_path
  end

	private

	def dish_params
		params.require(:dish).permit(:dishpicture, :title, :review)
	end
end
