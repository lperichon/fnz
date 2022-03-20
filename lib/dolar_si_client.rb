class DolarSiClient

  def initialize(attrs = {})
    @currency = attrs[:currency]
  end

  def self.use_for?(currency)
    currency.in?(%W(usd btc))
  end

  def current
    if (json = valoresprincipales)
      case @currency
        when "usd"
          json.detect { |c| c["casa"]["nombre"] == "Dolar Blue" }["casa"]["compra"]
        when "btc"
          json.detect { |c| c["casa"]["nombre"] == "Bitcoin" }["casa"]["compra"]
      end.to_f
    end
  end

  def valoresprincipales
    response = Typhoeus.get(url("/api/api.php"),{
      params: {
        type: "valoresprincipales"
      }
    })
    if response.success?
      JSON.parse response.body
    end
  end

  def url(endpoint)
    "#{host}#{endpoint}"
  end

  def host
    "https://www.dolarsi.com"
  end

end
