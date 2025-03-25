require "net/http"
require "net/https"
require "rack/utils"

module OpenEWS
  class Client
    attr_reader :http_client, :api_key

    def initialize(**options)
      @http_client = options.fetch(:http_client) { default_http_client(host: options.fetch(:host) { configuration.host }) }
      @api_key = options.fetch(:api_key) { configuration.api_key }
    end

    def fetch_account_settings
      do_request(Net::HTTP::Get.new(build_request_uri("/v1/account")), response_parser: ResponseParser::AccountParser.new)
    end

    def list_beneficiaries(**options)
      do_request(Net::HTTP::Get.new(build_request_uri("/v1/beneficiaries", query_parameters: options)), response_parser: ResponseParser::CollectionParser.new(ResponseParser::BeneficiaryParser.new))
    end

    def create_beneficiary(**params)
      payload = {
        data: {
          type: "beneficiary",
          attributes: params
        }
      }

      do_request(Net::HTTP::Post.new(build_request_uri("/v1/beneficiaries")), body: payload, response_parser: ResponseParser::BeneficiaryParser.new)
    end

    def create_beneficiary_address(beneficiary_id:, **params)
      payload = {
        data: {
          type: "address",
          attributes: {
            **params
          }
        }
      }

      do_request(Net::HTTP::Post.new(build_request_uri("/v1/beneficiaries/#{beneficiary_id}/addresses")), body: payload, response_parser: ResponseParser::BeneficiaryAddressParser.new)
    end

    private

    def build_request_uri(path, query_parameters: {})
      uri = URI(configuration.host)
      uri.path = path
      uri.query = Rack::Utils.build_nested_query(query_parameters)
      uri
    end

    def configuration
      OpenEWS.configuration
    end

    def do_request(req, response_parser:, body: nil)
      req.add_field("Content-Type", "application/vnd.api+json; charset=utf-8")
      req.add_field("Authorization", "Bearer #{configuration.api_key}")
      req.body = JSON.dump(body) if body
      response = http_client.request(req)
      response_parser.parse(response.body)
    end

    def default_http_client(host:)
      host_uri = URI(host)
      host_port = host_uri.port || 443
      http = Net::HTTP.new(host_uri.host, host_port)
      if host_port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http
    end
  end
end
