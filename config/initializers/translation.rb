TranslationIO.configure do |config|
  config.api_key        = '956262d3ffc94d1b9b30ca8dfa326586'
  config.source_locale  = 'es'
  config.target_locales = ['en', 'pt-BR']

  # Uncomment this if you don't want to use gettext
  # config.disable_gettext = true

  # Uncomment this if you already use gettext or fast_gettext
  # config.locales_path = File.join('path', 'to', 'gettext_locale')

  # Find other useful usage information here:
  # https://github.com/translation/rails#readme
end
