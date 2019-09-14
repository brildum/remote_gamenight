# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

module Config
  class Data
    extend T::Sig

    attr_reader :data

    sig do
      params(
        overrides: T::Hash[String, T.untyped],
        inherit: T.nilable(Data),
      ).void
    end
    def initialize(overrides, inherit: nil)
      @data = inherit.nil? ? {} : inherit.data.clone
      @data.update(overrides)
    end

    sig { params(key: String, default: T.untyped).returns(T.untyped) }
    def get(key, default: nil)
      return default if key.empty?

      parts = key.split('.')
      bucket = @data
      parts.each do |part|
        return default unless bucket.key?(part)

        bucket = bucket[part]
      end
      bucket
    end
  end

  Prod = Data.new({
    'website' => 'https://www.partygamesbot.com',
    'dbname' => 'gamenight_prod',
    'botname' => '@partygames',
  })

  Dev = Data.new(
    {
      'website' => 'https://f28893db.ngrok.io',
      'dbname' => 'gamenight_dev',
      'botname' => '@devpartygames',
    },
    inherit: Prod,
  )
end
