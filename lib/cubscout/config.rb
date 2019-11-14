# frozen_string_literal: true

require "oauth2"

module Cubscout
  # The Config class allows for API client configuration. Basic setup:
  #    require 'cubscout'
  #    Cubscout::Config.client_id = 'YOUR_APP_ID'
  #    Cubscout::Config.client_secret = 'YOUR_APP_SECRET'
  class Config
    DEFAULT_API_PREFIX = 'https://api.helpscout.net/v2'

    class << self
      attr_writer :api_prefix, :client_id, :client_secret

      # @return [String] Base url of Helpscout's API V2.
      def api_prefix
        @api_prefix ||= DEFAULT_API_PREFIX
      end

      # Resets +client_id+, +client_secret+, and +oauth_client+ to null values,
      # +api_prefix+ to DEFAULT_API_PREFIX
      def reset!
        @client_id = @client_secret = nil
        @access_token = @oauth_client = nil
        @api_prefix = DEFAULT_API_PREFIX
      end

      # @return [String] OAuth token used in every request header:
      #   +Authorization: Bearer #{Cubscout::Config.oauth_token}+
      def oauth_token
        access_token.token
      end

      private

      def access_token
        if @access_token && @access_token.expires_at > Time.now.to_i + 30
          return @access_token
        end

        @access_token = oauth_client.client_credentials.get_token
      end

      def oauth_client
        @oauth_client ||= begin
          unless @client_id && @client_secret
            raise ParameterMissing, <<~TEXT
              You need to provide a client_id and client secret that you can get from helpscout (In Your profile -> my Apps)

              Cubscout::Config.client_id = 'your-app-id-here'
              Cubscout::Config.client_secret = 'your-app-secret-here'

            TEXT
          end

          OAuth2::Client.new(@client_id, @client_secret, site: URI.join(api_prefix, '/').to_s, token_url: "#{URI::parse(api_prefix).path}/oauth2/token")
        end
      end
    end
  end
end
