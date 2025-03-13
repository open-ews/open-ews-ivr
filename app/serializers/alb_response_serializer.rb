class ALBResponseSerializer
  attr_reader :response

  def initialize(response)
    @response = response
  end

  def as_json
    {
      statusCode: response.status_code,
      statusDescription: response.status_description,
      isBase64Encoded: response.is_base64_encoded,
      headers: response.headers,
      body: response.body
    }
  end
end
