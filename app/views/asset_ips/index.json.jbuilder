json.array!(@targets) do |target|
  json.extract! target, :id, :name, :website, :memo
  json.url target_url(target, format: :json)
end
