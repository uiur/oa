# frozen_string_literal: true

require_relative "oa/version"
require_relative "oa/annotator"
require_relative "oa/config"
require_relative "oa/document"

module Oa
  class Error < StandardError; end

  def self.generate_documents
    config.documents.each do |document|
      document.generate_openapi
    end
  end
end
