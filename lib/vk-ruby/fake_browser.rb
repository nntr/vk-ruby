class VK::FakeBrowser

  def initialize(config)
    @config = config
  end

  def sign_in!(authorization_url, login, password)
    agent.get(authorization_url)

    agent.page.form_with(action: /login.vk.com/){ |form|
      form.email = login
      form.pass  = password
    }.submit
  rescue Exception => ex
    raise VK::AuthentificationError.new({
      error: 'Authentification error',
      description: 'invalid loging or password'
    })
  end

  def security_hack!(login)
    form = agent.page.form_with(action: /security_check/)

    if form
      hint = (agent.page / '.field_prefix').last.inner_html[1, 2]
      if login[/#{hint}$/]
        form['code'] = login[-10, 8]
        form.submit
      else
        raise VK::AuthentificationError.new({
          error: 'Authentification error',
          description: 'error 17'
        })
      end
    end
  end

  def authorize!
    if detect_cookie?
      url = agent.page
                 .body
                 .gsub("\n",'')
                 .gsub("  ",'')
                 .match(/.*function allow\(\)\s?\{.*}location.href\s?=\s?[\'\"\s](.+)[\'\"].+\}/)
                 .to_a
                 .last
      agent.get(url)
    else
      raise VK::AuthentificationError.new({
        error: 'Authorization error',
        description: 'invalid loging or password'
      })
    end
  end

  def response
    @response ||= agent.page
                       .uri
                       .fragment
                       .split('&')
                       .map{ |s| s.split '=' }
                       .inject({}){ |a, (k,v)| a[k] = v; a }
  end

  private

  def agent
    unless @agent
      @agent = Mechanize.new
      proxy = @config.proxy

      @agent.user_agent_alias = 'Mac Safari'
      @agent.set_proxy(proxy.uri.host, proxy.uri.port, proxy.user, proxy.password) if proxy
    end

    @agent
  end

  def detect_cookie?
    agent.cookies.detect{|cookie| cookie.name == 'remixsid'}
  end
  
end