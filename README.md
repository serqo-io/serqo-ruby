# Serqo Ruby SDK

Official Ruby client for the Serqo Search API. Requires Ruby 3.1 or later and uses the standard library.

## Install

```sh
gem install serqo
```

## Quick start

```ruby
require "serqo"

client = Serqo::Client.new(api_key: ENV.fetch("SERQO_API_KEY"))
response = client.search({
  "q" => "espresso machines",
  "engine" => "google",
  "type" => "web",
  "gl" => "us",
  "hl" => "en"
})

puts response.dig("data", "results")
puts "Request ID: #{response.fetch('requestId')}"
```

Keep the API key in server-side configuration. Methods return the full response envelope as hashes.

## Methods and errors

- `search(query, idempotency_key: nil)` sends `POST /v1/search`.
- `engines`, `me`, and `health` call the corresponding endpoints.
- API failures raise `Serqo::Error` with `status`, `code`, `request_id`, `retryable`, `retry_after_ms`, and `details`.
- The client never retries searches automatically. Reuse an idempotency key only with identical parameters.
- See the [shared API reference](API.md) for all search parameters, response fields, and pagination behavior.
