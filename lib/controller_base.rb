require 'active_support'
require 'erb'
require 'active_support/core_ext'
require 'active_support/inflector'
require_relative './session'
require_relative './params'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @params = Params.new(req, route_params)
    @req = req
    @res = res
  end

  def already_built_response?
    @already_built_response ||= false
  end

  def session
    @session ||= Session.new(@req)
  end

  def invoke_action(action_name)
    send(action_name)
    render(action_name) unless already_built_response?
  end

  def redirect_to(url)
    raise "already built response!" if already_built_response?
    @res.header["location"] = url.to_s
    @res.status = 302
    @already_built_response = true

    session.store_session(@res)
  end

  def render_content(content, content_type)
    raise "already built response!" if already_built_response?
    @res.content_type = content_type
    @res.body = content
    @already_built_response = true

    session.store_session(@res)
  end

  def render(template_name)
    raise "already built response!" if already_built_response?

    data = File.read("views/#{self.class.to_s.tableize.singularize}/#{template_name}.html.erb").gsub!("\n"," ")
    template = ERB.new(data)
    render_content(template.result(binding), "text/html")
  end
end
