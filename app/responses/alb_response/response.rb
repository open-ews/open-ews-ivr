module ALBResponse
  Response = Data.define(:status_code, :status_description, :is_base64_encoded, :headers, :body)
end
