CurrencyLoader.load_currencies
SUPPORTED_CURRENCIES = [:usd, :brl, :eur, :ars].map {|code| Currency.find(code)}