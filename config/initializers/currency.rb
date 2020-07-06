CurrencyLoader.load_currencies
SUPPORTED_CURRENCIES = [:usd, :brl, :eur, :ars, :dai].map {|code| Currency.find(code)}