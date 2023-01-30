class Recipe
  attr_reader :name, :description, :rating, :prep_time, :marked
  attr_writer :marked

  def initialize(name, description, rating, prep_time, marked)
    @name = name
    @description = description
    @rating = rating
    @prep_time = prep_time
    @marked = marked
  end
end
