# API request params wrapper

class VK::Params < Struct.new(:config, :options)

  def host
    (options[:host] || config.host).dup.tap{ |value| value.gsub!('https', 'http') unless ssl }
  end

  def verb
    options[:verb] || config.verb
  end

  def timeout
    options[:timeout] || config.timeout
  end

  def open_timeout
    options[:open_timeout] || config.open_timeout
  end

  def ssl
    options[:ssl] != false ? config.ssl.merge(options[:ssl] || {}) : false
  end

  def proxy
    if options[:proxy]
      proxy_options = Faraday::ProxyOptions.from(options[:proxy])
      config.proxy ? config.proxy.merge(proxy_options) : proxy_options
    else
      config.proxy
    end
  end

  def middlewares
    options[:middlewares] || config.middlewares
  end

  alias stack middlewares

  def query
    %w(host verb timeout open_timeout ssl proxy middlewares stack).map(&:to_sym).inject(options.dup) do |result, name|
      result.delete(name)
      result
    end
  end

end
