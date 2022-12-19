require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      # para que funcione en railway/docker
      false
    end
  end
end
