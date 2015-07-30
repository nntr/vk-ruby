# API error handler middleware
#
# @see http://rubydoc.info/gems/faraday

class VK::MW::APIErrors < Faraday::Response::Middleware

  def call(environment)
    @app.call(environment).on_complete do |env|
      if (env.body.is_a?(String) && env.body.include?("error")) || 
         (env.body.is_a?(Hash) && env.body.has_key?('error'))
        if env.url.host == 'oauth.vk.com'
          fail VK::AuthorizationError.new(env)
        else
          fail VK::APIError.new(env)
        end
      end
    end
  end

end
