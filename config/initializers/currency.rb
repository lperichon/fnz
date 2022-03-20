CurrencyLoader.load_currencies
SUPPORTED_CURRENCY_IDS = %W(usd brl eur ars dai)
SUPPORTED_CURRENCIES = SUPPORTED_CURRENCY_IDS.map {|code| Currency.find(code)}