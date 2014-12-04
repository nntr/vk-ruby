# Authorization and authentification methods

module VK::Auth

  # @!attribute [rw] expires_in
  #   @return [Fixnum] lifetime of the token
  attr_accessor :expires_in

  # @!attribute [r] access_token
  #   @return [String] current access token
  attr_accessor :access_token

  # Checking authorizing application
  #
  # @return [Boolean]
  def authorized?
    !!access_token
  end

  # Get current access token
  #
  # @return [String] access token (config.access_token)

  def access_token
    @access_token || config.access_token
  end

  # Get authorization URL
  #
  # @param [Hash] options required for serverside authorization
  # @option options [Symbol] :type application type, :client or :standalone or :site or :serverside
  # @option options [String] :app_id (config.app_id) application ID
  # @option options [String] :settings (config.settings) application settings flag separate by comma (see {https://vk.com/dev/permissions})
  # @option options [String] :version (config.version) API version
  # @option options [String] :redirect_uri (config.redirect_url or DEFAULT_CLIENT_REDIRECT_URL) redirect URL
  # @option options [Symbol] :display (:page) window type of authorization, :page or :popup or :mobile
  #
  # @return [String] authorization URL
  #
  # @example Get standalone/client authorization URL (see {https://vk.com/dev/auth_mobile})
  #   application.authorization_url({
  #     type: :client,
  #     app_id: 123,
  #     settings: 'friends,audio',
  #     version: '5.26',
  #     redirect_uri: 'https://example.com/',
  #     display: :mobile
  #   })
  #
  #   #=> "https://oauth.vk.com/authorize?client_id=123&scope=friends,audio&redirect_uri=https://example.com/&display=mobile&response_type=token&v=5.26"
  #
  # @example Get serverside authorization URL (see {https://vk.com/dev/auth_sites})
  #   application.authorization_url({
  #     type: :site,
  #     app_id: 123,
  #     settings: 'friends,audio',
  #     version: '5.26',
  #     redirect_uri: 'https://example.com/'
  #   })
  #
  #   #=> "https://oauth.vk.com/authorize?client_id=123&scope=friends,audio&redirect_uri=https://example.com/&response_type=token&v=5.26"

  def authorization_url(options)
    params = VK::AuthParams.new(config, options)

    params.check! :app_id, :redirect_url, :settings, :version

    case params.type
    when :client, :standalone
      "https://oauth.vk.com/authorize?" << URI.encode_www_form({
        client_id: params.app_id,
        scope: params.settings,
        redirect_uri: params.redirect_url,
        display: params.display,
        response_type: :token,
        v: params.version
      })
    when :site, :serverside
      "https://oauth.vk.com/authorize?" << URI.encode_www_form({
        client_id: params.app_id,
        scope: params.settings,
        redirect_uri: params.redirect_url,
        response_type: :token,
        v: params.version
      })
    end
  end

  # Site authorization (see {http://vk.com/dev/auth_sites})
  #
  # @param [Hash] options required for serverside authorization
  # @option options [String] :app_id (config.app_id) application ID
  # @option options [String] :app_secret (config.app_secret) application secret
  # @option options [String] :version (config.version) API version
  # @option options [String] :redirect_url (config.redirect_url) redirect URL
  # @option options [String] :code authorization code
  #
  # @return [Object] server response
  #
  # @raise [VK::AuthorizationError] if server response has error keys
  # @raise [VK::APIError] with API error
  #
  # @example Receive access token (see {https://vk.com/dev/auth_sites})
  #

  def site_auth(options={})
    params = VK::AuthParams.new(config, options)
    params.check! :code, :app_id, :app_secret, :version, :redirect_url

    query = {
      host: 'https://oauth.vk.com',
      client_id: params.app_id,
      client_secret: params.app_secret,
      code: params.code,
      redirect_uri: params.redirect_url,
      verb: :get,
      v: params.version
    }

    response = request(query) { |req| req.url "/access_token" }

    self.expires_in = response.body['expires_in']
    self.access_token = response.body['access_token']

    response.body
  end

  # Application secure server authorization (see {http://vk.com/dev/auth_server})
  #
  # @param [Hash] options required for serverside authorization
  # @option options [String] :app_id (config.app_id) application ID
  # @option options [String] :app_secret (config.app_secret) application secret
  #
  # @return [Object] server response
  #
  # @raise [VK::AuthorizationError] if server response has error keys
  # @raise [VK::APIError] with API error

  def server_auth(options={})
    params = VK::AuthParams.new(config, options)
    params.check! :app_id, :app_secret

    query = {
      host: 'https://oauth.vk.com',
      client_id: params.app_id,
      client_secret: params.app_secret,
      grant_type: :client_credentials,
      verb: :get
    }

    response = request(query) { |req| req.url "/access_token" }

    self.expires_in = 0
    self.access_token = response.body['access_token']

    response.body
  end

  # Client/standalone authentication and authorization (see {https://vk.com/dev/auth_mobile})
  #
  # @param [Hash] options required for serverside authorization
  # @option options [String] :app_id (config.app_id) application ID
  # @option options [String] :app_secret (config.app_secret) application secret
  # @option options [String] :settings (config.settings) application settings flag separate by comma (see {https://vk.com/dev/permissions})
  # @option options [String] :login user login
  # @option options [String] :password user password
  #
  # @return [Object] access token
  #
  # @raise [VK::AuthentificationError] with invalid login or password
  # @raise [VK::APIError] with API error

  def client_auth(options={})
    params = VK::AuthParams.new(config, options)
    params.check! :app_id, :settings, :login, :password

    url = authorization_url(app_id: params.app_id, settings: params.settings, type: :client) << '&revoke=1'

    browser = VK::FakeBrowser.new
    browser.sign_in! url, params.login, params.password
    sleep 1
    browser.authorize!

    self.expires_in = browser.response['expires_in']
    self.access_token = browser.response['access_token']

    browser.response
  end

end
