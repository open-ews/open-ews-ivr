require "ostruct"

module FactoryHelpers
  def build_request(**params)
    request_parameters = build_request_parameters(**params)

    Request.new(
      http_method: request_parameters.http_method,
      path: request_parameters.path,
      query_parameters: request_parameters.query_parameters,
      headers: request_parameters.headers,
      host: request_parameters.host,
      scheme: request_parameters.scheme,
      body: request_parameters.body,
      port: request_parameters.port,
      url: request_parameters.url
    )
  end

  def build_twilio_request(twilio: {}, **params)
    twilio_params = {
      from: "+855715100989",
      to: "1294",
      direction: "inbound",
      digits: nil,
      **twilio.fetch(:params, {})
    }
    twilio_params[:beneficiary] ||= twilio_params.fetch(:direction) == "inbound" ? twilio_params.fetch(:from) : twilio_params.fetch(:to)

    request_parameters = build_request_parameters(**params)
    payload = twilio.fetch(:payload) { twilio_params.compact.transform_keys { _1.to_s.camelize } }
    auth_token = twilio.fetch(:auth_token) { SecureRandom.alphanumeric(43) }
    signature = twilio.fetch(:signature) { build_twilio_signature(auth_token:, url: request_parameters.url, params: payload) }

    twilio = TwilioRequest::Twilio.new(payload:, signature:, **twilio_params)
    request = build_request(**params)

    TwilioRequest.new(request, twilio)
  end

  def build_twilio_signature(auth_token:, url:, params:, **options)
    request_validator = options.fetch(:request_validator) { TwilioRequestValidator.new }
    request_validator.build_signature_for(auth_token:, url:, params:)
  end

  def build_request_parameters(**params)
    headers = { "host" => "ivr.open-ews.org", "x-forwarded-proto" => "https" }.merge(params.fetch(:headers, {}))
    path = params.fetch(:path, "/")
    scheme = headers.fetch("x-forwarded-proto")
    host = headers.fetch("host")
    base_url = "#{scheme}://#{host}"
    query_parameters = params.fetch(:query_parameters, {})
    query_string = URI.encode_www_form(query_parameters)
    fullpath = query_string.empty? ? path : "#{path}?#{query_string}"
    url = base_url + fullpath

    Data.define(:http_method, :port, :body, :headers, :path, :scheme, :host, :query_parameters, :url).new(
      http_method: params.fetch(:http_method, :post),
      port: params.fetch(:port, 443),
      body: params.fetch(:body, ""),
      headers:,
      path:,
      scheme:,
      host:,
      query_parameters:,
      url:
    )
  end

  def build_beneficiary(**params)
    OpenEWS::Resource::Beneficiary.new(
      id: "1",
      phone_number: "855715100900",
      iso_country_code: "KH",
      addresses: [],
      **params
    )
  end

  def build_beneficiary_address(**params)
    OpenEWS::Resource::BeneficiaryAddress.new(
      iso_region_code: "KH-04",
      administrative_division_level_2_code: "0401",
      administrative_division_level_2_name: "Baribour",
      administrative_division_level_3_code: "040106",
      administrative_division_level_3_name: "Melum",
      administrative_division_level_4_code: nil,
      administrative_division_level_4_name: nil,
      **params
    )
  end

  def build_fake_open_ews_client(**options)
    client = instance_spy(OpenEWS::Client)
    allow(client).to receive(:list_beneficiaries).and_return(
      OpenEWS::Resource::Collection.new(resources: options.fetch(:list_beneficiaries, []))
    )
    client
  end
end

RSpec.configure do |config|
  config.include(FactoryHelpers)
end
