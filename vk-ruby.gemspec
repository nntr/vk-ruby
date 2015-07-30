# encoding: utf-8

$:.push File.expand_path('../lib', __FILE__)
require  'vk-ruby/version'

Gem::Specification.new do |gem|
  gem.name = "vk-ruby"
  gem.licenses = ["MIT"]
  gem.version = VK::VERSION
  gem.date = Time.now.strftime '%Y-%m-%d'

  gem.authors = ["Andrew Zinenko"]
  gem.email = "andrew@izinenko.ru"
  gem.homepage = "http://github.com/zinenko/vk-ruby"

  gem.summary = "Ruby wrapper for vk.com API"

  gem.description = <<-DESCRIPTION
VK-RUBY gives you full access to all vk.com API features.
Has several types of method naming and methods calling,
optional authorization, file uploading, logging,
irb integration, parallel method calling and
any faraday-supported http adapter of your choice.
DESCRIPTION

  gem.post_install_message = <<-THANKS
\n
##################################
#########################%%%######
#####;   +##############     %####
#####     `+#########%        ####
####%       #%%':+%#          ####
####+                %%      `####
#######+                  :+######
########'               `#########
#########  ,%:    '##.  %#########
#########` %##    ####  ##########
#########' %#%    ###%  ##########
#########%  ;     %##: .##########
##########          `  ;##########
##########`           ;###########
##########:   %+#:    ############
##########%  %####`  %############
###########+ %##+: %##############
############+`..  %###############
##############%#%#################

      Thanks for installing!
\n
THANKS

  gem.add_runtime_dependency 'faraday', '~> 0.9',  '>= 0.9.0'
  gem.add_runtime_dependency 'faraday_middleware', '~> 0.9',    '>= 0.9.1'
  gem.add_runtime_dependency 'multi_json',         '>= 1.10.1'
  gem.add_runtime_dependency 'jruby-openssl',      '>= 0.7.7'    if RUBY_PLATFORM == 'java'
  gem.add_runtime_dependency 'mechanize','~> 2.7', '>= 2.7'
  gem.add_runtime_dependency 'docopt',   '~> 0.5', '>= 0.5.0'
  gem.add_runtime_dependency 'highline', '~> 1.6', '>= 1.6.21'

  gem.add_development_dependency 'rake',      '~> 10.3', '>= 10.3.1'
  gem.add_development_dependency 'rspec',     '~> 2.14', '>= 2.14.1'
  gem.add_development_dependency 'pry',       '~> 0.9',  '>= 0.9.12.6'
  gem.add_development_dependency 'webmock',   '~> 1.17', '>= 1.17.4'
  gem.add_development_dependency 'json_pure', '~> 1.8',  '>= 1.8.1'

  gem.add_development_dependency 'net-http-persistent','~> 2.9', '>= 2.9.4'
  gem.add_development_dependency 'yard',               '~> 0.8', '>= 0.8.7.6'
  gem.add_development_dependency 'redcarpet',          '~> 3.0', '>= 3.1.2'
  gem.add_development_dependency 'github-markup',      '~> 1.2', '>= 1.2.1'

  unless RUBY_PLATFORM == 'java'
    gem.add_development_dependency 'oj',              '~> 2.8', '>= 2.8.1'
    gem.add_development_dependency 'yajl-ruby',       '~> 1.2', '>= 1.2.0'
    gem.add_development_dependency 'eventmachine',    '~> 1.0', '>= 1.0.3'
    gem.add_development_dependency 'em-synchrony',    '~> 1.0', '>= 1.0.3'
    gem.add_development_dependency 'em-http-request', '~> 1.1', '>= 1.1.2'
    gem.add_development_dependency 'patron',          '~> 0.4', '>= 0.4.18'
  end

  if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'rbx'
    gem.add_development_dependency 'typhoeus', '~> 0.6',  '>= 0.6.8'
  end

  gem.require_paths = ['lib']
  gem.files = `git ls-files -z`.split("\x0")
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables =  gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.extra_rdoc_files = ["LICENSE.txt", "README.md" ]
end
