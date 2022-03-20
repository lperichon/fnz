class OpenExchangeRatesClient

  def initialize(attrs = {})
    @base_cur = attrs[:from_cur]
    @symbols = attrs[:to_cur]
    if @base_cur.blank? || @symbols.blank?
      raise ArgumentError
    end
  end

  def historical(ref_date)
    response = Typhoeus.get(url("api/historical/#{ref_date.to_date.iso8601}.json"),{
      params: {
        app_id: app_id,
        base: @base_cur,
        symbols: @symbols
      }
    })
    if response.success?
      json = JSON.parse response.body
      json["rates"][@symbols]
    end
  end

  def url(endpoint)
    "#{host}#{endpoint}"
  end

  def host
    "https://openexchangerates.org/"
  end

  def app_id
    ENV["app_id"]
  end

end
