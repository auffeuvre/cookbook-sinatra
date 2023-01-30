require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require_relative 'cookbook'
require_relative "recipe"
require_relative "scrapeallrecipesservice"

set :bind, "0.0.0.0"

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path(__dir__)
end

csv_file   = File.join(__dir__, 'recipes.csv')
cookbook   = Cookbook.new(csv_file)

get "/" do
  erb :index
end

# get "/team/:username" do
#   binding.pry
#   puts params[:username]
#   "The username is #{params[:username]}"
# end

get "/display" do
  @recipes = cookbook.all
  erb :display
end

get "/add" do
  erb :add
end

post "/add" do
  @name = params[:name]
  @description = params[:description]
  recipe = Recipe.new(@name, @description, "5", "0", false)
  cookbook.create(recipe)
  redirect "/display"
end

get "/remove" do
  @recipes = cookbook.all
  erb :remove
end

post "/remove" do
  @index = params[:index]
  cookbook.destroy(@index.to_i - 1)
  redirect "/display"
end

get "/mark" do
  @recipes = cookbook.all
  erb :mark
end

post "/mark" do
  @index = params[:index]
  cookbook.mark_as_done(@index.to_i - 1)
  redirect "/display"
end

get "/import" do
  erb :import
end

post "/import" do
  @keyword_search = params[:keyword_search]
  redirect "/import/#{@keyword_search}"
end

get "/import/:keyword_search" do
  @keyword_search = params[:keyword_search]
  import_service = ScrapeAllrecipesService.new(@keyword_search)
  @recipe_array = import_service.call
  erb :import
end

post "/import/:keyword_search" do
  @index = params[:index].to_i
  @keyword_search = params[:keyword_search]
  # erb :import
  import_service = ScrapeAllrecipesService.new(@keyword_search)
  @recipe_array = import_service.call
  recipe_choosen_infos = cookbook.import_description_rating_prep_time(@recipe_array[@index - 1][1])
  name = @recipe_array[@index - 1][0]
  description = recipe_choosen_infos[1]
  rating = recipe_choosen_infos[0]
  prep_time = recipe_choosen_infos[2]
  cookbook.create(Recipe.new(name, description, rating, prep_time, false))
  redirect "/display"
end
