# frozen_string_literal: true

require 'spec_helper'

RSpec.describe App do
  include Rack::Test::Methods

  let(:app) { described_class }

  def json_response_body
    JSON.parse(last_response.body)
  end

  describe 'GET /' do
    it 'gets text' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to eq 'Welcome to Node Playground!'
    end
  end

  describe 'POST /generate-ast' do
    describe 'generates ast node' do
      it 'gets node from source code' do
        code = 'class Synvert; end'
        post '/generate-ast', { code: code }.to_json

        expect(last_response).to be_ok
        expect(json_response_body).to eq(
          {
            "node" => {
              "type" => "class",
              "name" => {
                "type" => "const",
                "parent_const" => nil,
                "name" => "Synvert"
              },
              "parent_class" => nil,
              "body" => []
            }
          }
        )
      end

      it 'raises error if source code is invalid' do
        code = 'class Synvert; en'
        post '/generate-ast', { code: code }.to_json

        expect(last_response).to be_bad_request
        expect(json_response_body).to eq({ 'error' => 'unexpected token $end' })
      end
    end
  end

  describe 'POST /parse-nql' do
    it 'gets ranges' do
      nql = '.class'
      code = 'class Synvert; end'
      post '/parse-nql', { nql: nql, code: code }.to_json

      expect(last_response).to be_ok
      expect(json_response_body).to eq('ranges' => [{ 'start' => { 'line' => 1, 'column' => 0 }, 'end' => { 'line' => 1, 'column' => 18 } }])
    end
  end
end
