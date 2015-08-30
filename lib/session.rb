require 'json'
require 'webrick'

class Session

  def initialize(req)
    rails_lite_cookie = req.cookies.select { |cookie| cookie.name == '_rails_lite_app' }.first
    if rails_lite_cookie
      @session_cookie = JSON.parse(rails_lite_cookie.value)
    else
      @session_cookie = {}
    end
  end

  def [](key)
    @session_cookie[key]
  end

  def []=(key, val)
    @session_cookie[key] = val
  end

  def store_session(res)
    res.cookies << WEBrick::Cookie.new('_rails_lite_app', @session_cookie.to_json)
  end

end
