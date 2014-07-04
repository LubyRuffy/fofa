json.array!(@rules) do |rule|
  json.extract! rule, :id, :product, :producturl, :rule
  json.url rule_url(rule, format: :json)
end
