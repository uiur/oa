module Oa
  module Annotator
    class Context
    end

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do

      end
    end

    module ClassMethods
      def openapi_document(name)
        @openapi_document_name = name
      end

      def openapi_document_name
        return @openapi_document_name if @openapi_document_name
        if superclass.respond_to?(:openapi_document_name)
          superclass.openapi_document_name
        end
      end

      def openapi(&block)
        paths = Context.new.instance_eval(&block)
        add_openapi_paths(paths)
      end

      def add_openapi_paths(paths)
        documents = Oa.config.documents

        document =
          if documents.size == 1
            documents.first
          else
            unless openapi_document_name
              raise Oa::Error.new('Target document name is not specified. Use `openapi_document` method to set document name.')
            end

            documents.find { |document| document.name.to_sym == openapi_document_name.to_sym }
          end

        unless document
          raise Oa::Error.new("document `#{openapi_document_name}` is not found")
        end

        document.add_paths(self.name, paths)
      end
    end
  end
end
