class OpenExchangeRatesClient

  FREE_BASE_CURRENCY = "USD"

  # @param attrs
  # @option from_cur [String] FROM currency iso_code
  # @option to_cur [String] TO currency iso_code
  def initialize(attrs = {})
    @from = attrs[:from_cur]
    @to = attrs[:to_cur]
    if @from.blank? || @to.blank?
      raise ArgumentError
    end
  end

  # Current (latest) @from -> @to exchange rate
  def latest
    if @from == "usd"
      free_latest(@to)
    elsif @to == "usd"
      if (t = free_latest(@from))
        1 / t
      end
    else
      # brl -> ars = usd -> ars / usd -> brl
      if (base_to_from = free_latest(@from)) && (base_to_to = free_latest(@to))
        base_to_to / base_to_from
      end
    end
  end

  # @from -> @to exchange rate at given date
  # @param ref_date [Date]
  def historical(ref_date)
    if @from == "usd"
      free_historical(@to, ref_date)
    elsif @to == "usd"
      if (t = free_historical(@from, ref_date))
        1 / t
      end
    else
      # brl -> ars = usd -> ars / usd -> brl
      if (base_to_from = free_historical(@from, ref_date)) && (base_to_to = free_historical(@to, ref_date))
        base_to_to / base_to_from
      end
    end
  end

  # Free usage for OpenExchangeRates only allows USD exchange rates.
  # This returns latest usd -> currency
  #
  # @param currency [String] iso_code for currency
  def free_latest(currency)
    Rails.cache.fetch(["OpenExchangeRates","usd","latest",currency], expire_in: 1.day) do
      response = Typhoeus.get(url("api/latest.json"),{
        params: {
          app_id: app_id,
          base: FREE_BASE_CURRENCY,
          symbols: Currency.find(currency).iso_code
        }
      })
      if response.success?
        json = JSON.parse response.body
        json["rates"][Currency.find(currency).iso_code]
      end
    end
  end

  # Free usage for OpenExhangeRates only allows USD exchange rates.
  # This returns usd -> currency exchange rate at given date
  #
  # @param currency [String] iso_code for currency
  # @param ref_date [Date]
  def free_historical(currency, ref_date)
    Rails.cache.fetch(["OpenExchangeRates","usd","historical",ref_date.to_date.iso8601,currency], expire_in: 1.day) do
      response = Typhoeus.get(url("api/historical/#{ref_date.to_date.iso8601}.json"),{
        params: {
          app_id: app_id,
          base: FREE_BASE_CURRENCY,
          symbols: Currency.find(currency).iso_code
        }
      })
      if response.success?
        json = JSON.parse response.body
        json["rates"][Currency.find(currency).iso_code]
      end
    end
  end

  def url(endpoint)
    "#{host}#{endpoint}"
  end

  def host
    "https://openexchangerates.org/"
  end

  def app_id
    ENV["OPEN_EXCHANGE_RATES_API_KEY"]
  end

end
