require "net/https"
require "uri"
require "json"
require "logger"

class UnofficialBuildkiteClient
  class JsonApiClient
    def initialize(authorization_header: nil)
      @authorization_header = authorization_header
    end

    def request(method, url, params: nil)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      logger.info("method: #{method}, url: #{url}, params: #{params.inspect}")

      request =
      case method
      when :get
        uri.query = URI.encode_www_form(params) if params
        Net::HTTP::Get.new(uri.request_uri)
      when :post
        Net::HTTP::Post.new(uri.request_uri).tap do |req|
          req.body = params.to_json if params
        end
      else
        raise NotImplementedError
      end

      json_headers.each do |k, v|
        request[k] = v
      end
      response = http.request(request)
      raise Error.new("#{response.inspect}") unless response.code.start_with?("2")
      JSON.parse(response.body, symbolize_names: true)
    end

    private

    def json_headers
      h = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
      }
      h.merge!("Authorization" => @authorization_header)
      h
    end

    def logger
      UnofficialBuildkiteClient.logger
    end
  end
end
