require "csv"
require_relative "recipe"
require 'nokogiri'
require 'open-uri'

class Cookbook
  def initialize(csv_file)
    @recipes = [] # <--- <Recipe> instances
    @csv_file = csv_file
    load_csv
  end

  def create(recipe)
    @recipes << recipe
    save_to_csv
  end

  def destroy(index)
    @recipes.delete_at(index)
    save_to_csv
  end

  def all
    return @recipes
  end

  def import_from_internet(keyword_search)
    url = "https://www.allrecipes.com/search?q=#{keyword_search}"

    html_file = URI.open(url, "User-Agent" => "Mozilla/5.0 (Linux; Android 7.0; SAMSUNG SM-G930T Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/5.0 Chrome/51.0.2704.106 Mobile Safari/537.36").read
    html_doc = Nokogiri::HTML.parse(html_file)

    data_scraped = []

    html_doc.search(".comp.mntl-card-list-items.mntl-document-card.mntl-card.card.card--no-image")[0..4].each do |element|
      data_scraped << [element.css(".card__title-text").text.strip, element.attributes['href']]
    end
    data_scraped
  end

  def import_description_rating_prep_time(recipe_url)
    html_file = URI.open(recipe_url, "User-Agent" => "Mozilla/5.0 (Linux; Android 7.0; SAMSUNG SM-G930T Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/5.0 Chrome/51.0.2704.106 Mobile Safari/537.36").read
    html_doc = Nokogiri::HTML.parse(html_file)
    recipe_details = []
    html_doc.search("article").each do |element|
      recipe_details << element.css("#mntl-recipe-review-bar__rating_2-0").text.strip
      recipe_details << element.css("#article-subheading_2-0").text.strip
      recipe_details << element.css(".mntl-recipe-details__value").text.strip.split.first
    end
    recipe_details
  end

  def mark_as_done(index)
    @recipes[index].marked = true
  end

  private

  def load_csv
    CSV.foreach(@csv_file) do |row|
      @recipes << Recipe.new(row[0], row[1], row[2], row[3], row[4] == "true" ? true : false)
    end
  end

  def save_to_csv
    CSV.open(@csv_file, 'wb') do |csv|
      @recipes.each do |recipe|
        csv << [ recipe.name, recipe.description, recipe.rating, recipe.prep_time, recipe.marked ]
      end
    end
  end


end
