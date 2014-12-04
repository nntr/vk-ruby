# Application configuration wrapper
#
# @see http://rubydoc.info/gems/faraday/Faraday/Options

class VK::Config < Faraday::Options.new(:app_id, :app_secret, :version, :redirect_uri, :settings,
                                      :access_token, :verb, :host, :proxy, :ssl, :timeout,
                                      :open_timeout, :middlewares, :parallel_manager)

  # @!attribute [rw] app_id
  #   @return [String] application ID
  #
  # @!attribute [rw] app_secret
  #   @return [String] application Secret
  #
  # @!attribute [rw] version
  #   @return [String] API version
  #
  # @!attribute [rw] redirect_uri
  #   @return [String] application redirect URL
  #
  # @!attribute [rw] settings
  #   @return [String] application settings (see {https://vk.com/dev/permissions})
  #
  # @!attribute [rw] access_token
  #   @return [String] application access token
  #
  # @!attribute [rw] verb
  #   @return [String] HTTP verb
  #
  # @!attribute [rw] host
  #   @return [String] API host
  #
  # @!attribute [rw] proxy
  #   @return [Faraday::ProxyOptions] proxy settings (see {https://github.com/lostisland/faraday})
  #
  # @!attribute [rw] ssl
  #   @return [Faraday::SSLOptions] ssl settings (see {https://github.com/lostisland/faraday})
  #
  # @!attribute [rw] timeout
  #   @return [Fixnum] http request timeout
  #
  # @!attribute [rw] open_timeout
  #   @return [Fixnum] open http request timeout
  #
  # @!attribute [rw] middlewares
  #   @return [Proc] Faraday middlewares stack (see {https://github.com/lostisland/faraday})
  #
  # @!attribute [rw] parallel_manager
  #   @return [Faraday::Adapter::EMHttp::Manager|Faraday::Adapter::EMSynchrony::ParallelManager] manager that this connection's adapter uses (see {https://github.com/lostisland/faraday})

  alias v version
  alias v= version=

  alias redirect_url redirect_uri
  alias redirect_url= redirect_uri=

  alias scope settings
  alias scope= settings=

  alias stack middlewares
  alias stack= middlewares=

  DEFAULT = {
    settings: 'notify,friends,offline',
    version: '5.26',
    host: 'https://api.vk.com',
    verb: :post,
    timeout: 10,
    open_timeout: 3,
    ssl: {
      verify: true,
      verify_mode: ::OpenSSL::SSL::VERIFY_NONE
    }
  }

  DEFAULT_STACK =  proc do |faraday|
    faraday.request :multipart
    faraday.request :url_encoded

    faraday.response :api_errors
    faraday.response :json, content_type: /\bjson$/
    faraday.response :http_errors

    faraday.adapter Faraday.default_adapter
  end

  # Initialize a new VK::Config instance
  #
  # @param [Hash] params attributes values for the new config
  #
  # @yieldparam config [VK::Config] self

  def initialize(params={})
    params = VK::Utils.deep_merge(DEFAULT, params.dup)
    params.each { |k,v| send("#{k}=", v) if respond_to?("#{k}=") }

    self.proxy = Faraday::ProxyOptions.from(self.proxy) if self.proxy
    self.ssl = Faraday::SSLOptions.from(self.ssl) if self.ssl
    self.middlewares ||= DEFAULT_STACK

    yield self if block_given?
  end

  def merge!(params)
    params = params.dup

    if ssl_options = params.delete(:ssl)
      self.ssl = self.ssl ? self.ssl.merge!(ssl_options) : Faraday::SSLOptions.from(ssl_options)
    end

    if proxy_options = params.delete(:proxy)
      self.proxy = self.proxy ? self.proxy.merge!(proxy_options) : Faraday::ProxyOptions.from(proxy_options)
    end

    params.each { |k,v| send("#{k}=", v) if respond_to?("#{k}=") }
  end

  def to_h
    super.tap do |h|
      h[:ssl] = h[:ssl].to_h if h[:ssl]
      h[:proxy] = h[:proxy].to_h if h[:proxy]
    end
  end

end