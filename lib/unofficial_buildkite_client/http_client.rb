require "net/https"
require "uri"
require "json"

class UnofficialBuildkiteClient
  class HttpClient
    def initialize(authorization_header: nil, logger:)
      @authorization_header = authorization_header
      @logger = logger
    end

    def request(method, url, params: nil, json: true, auth: true)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      logger.info("method: #{method} url: #{url} params: #{params.inspect}")

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

      request["Content-Type"] = request["Accept"] = "application/json" if json
      request["Authorization"] = @authorization_header if auth

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        if json
          JSON.parse(response.body, symbolize_names: true)
        else
          response.body
        end
      when Net::HTTPRedirection
        request(:get, response["location"], json: json, auth: false)
      else
        response.error!
      end
    end

    private

    attr_reader :logger

    def json_headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
      }
    end
  end
end
