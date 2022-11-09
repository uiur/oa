# frozen_string_literal: true

RSpec.describe Oa do
  it "has a version number" do
    expect(Oa::VERSION).not_to be nil
  end

  before(:each) do
    Oa.config = nil
  end

  describe '.generate_documents' do
    let(:document)  do
      Oa::Document.new(
        name: :api,
        path: 'tmp/spec/openapi/api.yml',
        root: {}
      )
    end

    it 'calls generate_openapi for each document'do
      Oa.config.documents = [document]
      expect(document).to receive(:generate_openapi)
      Oa.generate_documents
    end
  end

  describe 'annotation' do
    let(:document) do
      Oa::Document.new(
        name: :api,
        path: 'tmp/spec/openapi/api.yml',
        root: {
          openapi: '3.0.0',
          info: {
            title: 'api',
            version: '1.0.0'
          }
        }
      )
    end

    before do
      Oa.configure do |config|
        config.documents = [document]
      end

      class BaseController
        include Oa::Annotator
        openapi_document :api
      end

      class UsersController < BaseController
        openapi do
          {
            '/users/{id}' => {
              get: {
                parameters: [
                  { name: :id, schema: { type: :integer }, in: :path, required: true }
                ],
                responses: {
                  '200': {
                    content: {
                      'application/json' => {
                        schema: {
                          type: :object,
                          properties: {
                            id: { type: :integer },
                            name: { type: :string },
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        end
        def show
          { id: 1, name: 'bar' }
        end
      end
    end

    it 'builds openapi in document' do
      expect(document.to_openapi).to match(hash_including(
        paths: {
          '/users/{id}' => Hash
        }
      ))
    end
  end
end
