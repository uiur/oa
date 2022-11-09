require 'spec_helper'

RSpec.describe Oa::Document do
  let(:document) do
    Oa::Document.new(
      name: :api,
      path: 'tmp/spec/openapi/api.yml',
      root: {
        openapi: '3.0.0',
        info: {
          title: 'api',
          version: '1.0.0'
        },
      }
    )
  end

  describe '#to_openapi' do
    it 'renders openapi document' do
      document.add_paths(
        'UsersController',
        {
          '/users' => {
            get: {
              # ...
            }
          }
        }
      )

      document.add_paths(
        'UsersController',
        {
          '/users' => {
            post: {
              # ...
            }
          }
        }
      )

      expect(document.to_openapi).to match(hash_including(
        openapi: '3.0.0',
        paths: {
          '/users' => {
            get: {},
            post: {},
          }
        }
      ))
    end
  end

  describe '#generate_openapi' do
    require 'fileutils'
    before do
      FileUtils.rm_f(document.path)
    end

    it do
      document.add_paths('UsersController', {
        '/users' => {
          post: {}
        }
      })
      document.generate_openapi
      expect(File.exist?(document.path)).to eq(true)
    end
  end
end
