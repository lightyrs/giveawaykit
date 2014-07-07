class GabbaClient

  def initialize
    @client = Gabba::Gabba.new( Garails.ga_account, "simplegiveaways.com" )
  end

  def event(*args)
    options = args.extract_options!
    @client.event( options[:category],
                   options[:action],
                   options[:label],
                   options[:value],
                   true )
  end
end
