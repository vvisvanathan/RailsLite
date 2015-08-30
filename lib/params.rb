require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string) if req.query_string
    parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    @params[key.to_sym] || @params[key.to_s]
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  def parse_www_encoded_form(www_encoded_form)
    return nil if www_encoded_form == nil

    decoded_form = URI.decode_www_form(www_encoded_form)

    decoded_form.each do |element|
      current = @params
      splitblock = parse_key(element.first)
      splitblock[0...-1].each do |key|
        current[key] ||= {}
        current = current[key]
      end
      current[splitblock.last] = element.last
    end

    p @params
    @params
  end

  def parse_key(key)
    key_array = key.split(/\]\[|\[|\]/)
  end

end
