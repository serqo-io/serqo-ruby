# Serqo Ruby SDK

Official Ruby client for the [Serqo Search API](https://serqo.io). Retrieve clean, structured Google & Bing SERP results in JSON with zero proxy setup. Get started with 100 free requests on [serqo.io](https://serqo.io).

Requires Ruby 3.1 or later and uses the standard library without external dependencies.

## Install

```sh
gem install serqo
```

## Quick start

```ruby
require "serqo"

client = Serqo::Client.new(api_key: ENV.fetch("SERQO_API_KEY"))

# Web Search
response = client.search({
  "q" => "espresso machines",
  "engine" => "google",
  "type" => "web",
  "gl" => "us",
  "hl" => "en"
})

puts response.dig("data", "results")
puts "Request ID: #{response.fetch('requestId')}"

# Autocomplete / Search Suggestions
suggestions = client.autocomplete({
  "q" => "artificial intell",
  "engine" => "google",
  "gl" => "us",
  "hl" => "en"
})

suggestions.dig("data", "suggestions")&.each do |item|
  puts item["text"]
end
```

Keep the API key in server-side configuration. Methods return the full response envelope as hashes.

## Methods and errors

- `search(query, idempotency_key: nil)` sends `POST /v1/search`.
- `autocomplete(query, idempotency_key: nil)` sends `POST /v1/autocomplete` for real-time query suggestions or expansion.
- `engines`, `me`, and `health` call the corresponding endpoints.
- API failures raise `Serqo::Error` with `status`, `code`, `request_id`, `retryable`, `retry_after_ms`, and `details`.
- The client never retries searches automatically. Reuse an idempotency key only with identical parameters.
- See the [Serqo API Documentation](https://serqo.io/docs) and [shared API reference](API.md) for all search parameters, response fields, and pagination behavior.
