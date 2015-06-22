require 'pry'
require 'net/http'
class ExperiencesController < ApplicationController
	def show
		@experience = Experience.find_by(id: params[:id])
    respond_to do |format|
      format.html{render :layout => !request.xhr?}
    end
	end

  def index
    if params[:user]
      @experiences = Experience.where(user_id: params[:user])
    elsif params[:search]
      @experiences = get_search_results(params[:search])
    else
      @experiences = Experience.all.includes(:dishes)
    end
    respond_to do |format|
      format.html{render :layout => !request.xhr?}
    end
  end

  def new
    @experience = Experience.new
    @venue = Venue.new
    @experience.dishes.build
    respond_to do |format|
      format.html{render :layout => !request.xhr?}
    end
  end

  def create
    place_id = params[:place_id]
    key = ENV["GOOGLE_KEY"]
    uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&key=#{key}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    place = JSON.parse(response.body)
    street_num = place["result"]["address_components"][0]["long_name"]
    street_address = place["result"]["address_components"][1]["long_name"]
    city = place["result"]["address_components"][2]["long_name"]
    state = place["result"]["address_components"][3]["short_name"]
    zip = place["result"]["address_components"][5]["long_name"]
    phone = place["result"]["formatted_phone_number"]
    website = place["result"]["website"]
    @venue = Venue.new(name: place["result"]["name"], address: "#{street_num} #{street_address}", city: city , state: state, zip: zip, phone: phone, website: website)
    @experience = current_user.experiences.build(name: experience_params[:name])
    @dish = @experience.dishes.build(experience_params[:dish])
    @dish.venue = @venue
    if @venue.save && @experience.save && @dish.save
      redirect_to experience_path(@experience)
    else
      render :new
    end
  end

  def search
    redirect_to :action => "index", :search => params[:search]
  end

  def edit
    @experience = Experience.find_by(id: params[:id])
  end

  def destroy
    @experience = Experience.find_by(id: params[:id])
    @experience.destroy
    redirect_to experiences_path
  end

  private

  def experience_params
    params.require(:experience).permit(:name, dish: [:id, :title, :dishpicture, :review])
  end

  def get_search_results(keyword)
    results = []
    PgSearch.multisearch(keyword).each do |object|
      if object.searchable_type == "Dish"
        results << object.searchable.experience unless results.include?(object.searchable.experience)
      elsif object.searchable_type == "User"
        results += object.searchable.experiences
      elsif object.searchable_type == "Experience"
        results << object.searchable
      end
    end
    Dish.venue_search(keyword).each do |object|
      results << object.experience unless results.include?(object.experience)
    end
    return results
  end
end
