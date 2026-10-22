# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Serqo
  # Structured API error. Inspect status, code, request_id, and retryable.
  class Error < StandardError
    attr_reader :status, :code, :request_id, :retryable, :retry_after_ms, :details

    def initialize(status:, body: {}, request_id: nil)
      @status = status
      @code = body["code"] || "UNKNOWN_ERROR"
      @request_id = request_id
      @retryable = body.fetch("retryable", false)
      @retry_after_ms = body["retryAfterMs"]
      @details = body["details"]
      super(body["message"] || "Serqo API request failed with HTTP #{status}")
    end
  end

  # Small standard-library client for the public Serqo Search API.
  class Client
    DEFAULT_BASE_URL = "https://api.serqo.io"

    # @param api_key [String] Secret key; keep it in trusted server config.
    # @param base_url [String] API origin without a trailing slash.
    # @param timeout [Integer] Read timeout in seconds (default 60).
    def initialize(api_key:, base_url: DEFAULT_BASE_URL, timeout: 60)
      raise ArgumentError, "api_key is required" if api_key.strip.empty?

      @api_key = api_key
      @base_url = base_url.sub(%r{/+\z}, "")
      @timeout = timeout
    end

    # Run one search. Pass an idempotency key only when retrying the same query.
    def search(query, idempotency_key: nil)
      headers = {}
      headers["Idempotency-Key"] = idempotency_key if idempotency_key
      request("POST", "/v1/search", body: query, headers: headers)
    end

    # Return the current engine and search-type capability list.
    def engines
      request("GET", "/v1/engines")
    end

    # Return account and key identifiers associated with this API key.
    def me
      request("GET", "/v1/me")
    end

    # Check the product API process without sending an API key.
    def health
      request("GET", "/v1/health", authenticated: false)
    end

    private

    def request(method, path, body: nil, headers: {}, authenticated: true)
      uri = URI("#{@base_url}#{path}")
      request_class = method == "POST" ? Net::HTTP::Post : Net::HTTP::Get
      http_request = request_class.new(uri)
      http_request["Accept"] = "application/json"
      http_request["x-api-key"] = @api_key if authenticated
      headers.each { |name, value| http_request[name] = value }
      http_request.body = JSON.generate(body) if body
      http_request["Content-Type"] = "application/json" if body

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 10, read_timeout: @timeout) do |http|
        http.request(http_request)
      end
      payload = JSON.parse(response.body)
      unless response.is_a?(Net::HTTPSuccess)
        error_body = payload.is_a?(Hash) ? (payload["error"] || {}) : {}
        request_id = payload.is_a?(Hash) ? payload["requestId"] : nil
        raise Error.new(status: response.code.to_i, body: error_body, request_id: request_id || response["x-request-id"])
      end
      raise Error.new(status: response.code.to_i, body: { "code" => "INVALID_RESPONSE" }) unless payload.is_a?(Hash) && payload["success"] == true

      payload
    end
  end
end
