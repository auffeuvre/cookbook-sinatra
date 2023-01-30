class ScrapeAllrecipesService
  def initialize(keyword)
    @keyword = keyword
  end

  def call
    url = "https://www.allrecipes.com/search?q=#{@keyword}"

    html_file = URI.open(url, "User-Agent" => "Mozilla/5.0 (Linux; Android 7.0; SAMSUNG SM-G930T Build/NRD90M) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/5.0 Chrome/51.0.2704.106 Mobile Safari/537.36").read
    html_doc = Nokogiri::HTML.parse(html_file)

    data_scraped = []

    html_doc.search(".comp.mntl-card-list-items.mntl-document-card.mntl-card.card.card--no-image")[0..4].each do |element|
      data_scraped << [element.css(".card__title-text").text.strip, element.attributes['href']]
    end
    data_scraped
  end
end
