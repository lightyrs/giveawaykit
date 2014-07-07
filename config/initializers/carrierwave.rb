module CarrierWave
  module MiniMagick
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end

    def strip
      manipulate! do |img|
        img.strip
        img = yield(img) if block_given?
        img
      end
    end
  end
end

CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: S3_ACCESS_KEY,
    aws_secret_access_key: S3_SECRET,
    region: 'us-east-1'
  }
  config.fog_directory  = "gk-#{RACK_ENV}"
end
