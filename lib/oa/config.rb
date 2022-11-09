module Oa
  class << self
    def configure
      yield config
    end

    def config
      @_config ||= Config.new
    end

    def config=(config)
      @_config = config
    end
  end

  class Config
    attr_reader :documents
    def initialize
      @documents = []
    end

    def documents=(documents)
      @documents = documents
    end

    def include(mod)
      ::Oa::Annotator::Context.include(mod)
    end
  end
end
