require 'spec_helper'

RSpec.describe Oa::Config do
  before(:each) do
    Oa.config = nil
  end
  let(:document) do
    Oa::Document.new(
      name: :api,
      path: 'tmp/openapi/api.yml',
      root: {
        openapi: '3.0.0',
        info: {
          title: 'api',
          version: '1.0.0'
        },
      }
    )
  end

  describe '#documents' do
    it 'can register documents' do
      Oa.configure do |config|
        config.documents = [document]
      end

      expect(Oa.config.documents.size).to eq(1)
    end
  end

  describe '#include' do
    module DSL
      def string
        { type: :string }
      end
    end

    it 'can include module in annotation context' do
      Oa.configure do |config|
        config.include DSL
        config.documents = [document]
      end

      Class.new do
        include Oa::Annotator

        def self.name
          'Class'
        end

        openapi do
          {
            '/users/{id}' => {
              get: {
                responses: {
                  '200' => {
                    content: {
                      'application/json' => {
                        schema: {
                          type: :object,
                          properties: {
                            name: string  # does not raise error
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
        end
      end
    end
  end
end
