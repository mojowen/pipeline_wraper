require 'ostruct'
require 'rest-client'

class PipelineRequest < OpenStruct
  def start
    self.class.post(to_json)['id']
  end

  def to_json
    to_h.to_json
  end

  class << self
    def post(data, path = '/tasks/')
      send_request :post, data, path
    end

    def get(path = '/tasks/')
      send_request :get, {}, path
    end

    def send_request(method, data, path)
      headers = {
        authorization: "Token #{ENV['TASK_AUTH_TOKEN']}",
        content_type: :json,
        accepts: :json
      }

      url = "#{ENV['TASK_SERVER_URL']}#{path}"

      if method == :get
        result = RestClient.get(url, **headers) do |resp, req|
          respond resp, req
        end
      else
        result = RestClient.send(method, url, data, **headers) do |resp, req|
          respond resp, req
        end
      end

      result
    end

    def respond(response, request)
      begin
        json = JSON.parse response.to_s
        return json if [200, 201].index response.code
      rescue JSON::ParserError
        json = { 'error' => response.to_s }
      end

      fail ["Status Code: #{response.code}",
            "Request: #{request.to_json}",
            "Error: #{json['error']}",
            "Traceback: #{json['traceback']}"].join("\n")
    end
  end
end
