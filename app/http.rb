# frozen_string_literal: true

# typed: strict

require 'json'

require 'sinatra'
require 'sorbet-runtime'

# JSONResponse returns HTTP response by converting the body param to JSON.
class JSONResponse < Sinatra::Response
  extend T::Sig

  sig { params(body: T.untyped, status: Integer, header: T::Hash[String, String]).void }
  def initialize(body, status = 200, header = {})
    header['Content-Type'] = 'application/json'
    super(body.to_json, status, header)
  end
end
