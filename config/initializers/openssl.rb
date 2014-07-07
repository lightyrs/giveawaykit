# -*- encoding : utf-8 -*-
require 'openssl'
require 'open-uri'
require 'net/https'

module Net
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=
    def use_ssl=(flag)
      self.ca_file = "#{Rails.root}/config/curl-ca-bundle.crt"
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER # ruby default is VERIFY_NONE!
      self.original_use_ssl = flag
    end
  end
end
