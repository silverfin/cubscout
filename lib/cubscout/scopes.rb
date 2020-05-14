module Cubscout
  # The Scopes module allows for Active Record kind of queries like .all and .find
  # this module is included in Object, meaning that every subclass of Object can
  # call the Scopes ClassMethods.
  # @example
  #  class Foo < Object; end
  #  Foo.find(id)
  #  Foo.all(page: 1)
  module Scopes
    module ClassMethods
      # DSL: necessary to provide the endpoint of the resources to query.
      # @param path [String] path to the endpoint, without leading slash
      # @example
      #   class Conversation
      #     include Cubscout::Scopes
      #     endpoint "conversations"
      #   end
      def endpoint(path)
        @path = path
      end

      # Read the path entered through the DSL
      def path
        @path
      end

      # used with a collection endpoint, get all objects of a certain kind
      # @param options [Hash] Optional query params described in Helspcout API documentation
      # @return [Cubscout::List] Returns a List collection where items are instances of the class where the method is called.
      # @example
      #   foos = Foo.all(tag: "bar")
      #   foos.total_size # 335 with this filter
      #   foos.each { |foo_element| puts "ID is #{foo_element.id}" }
      def all(options = {})
        raise Error, "`#{self}.all` method is not available" unless path

        raw_first_or_requested_page = Cubscout.connection.get(path, page: options[:page] || 1, **options).body
        first_or_requested_page = List.new(raw_first_or_requested_page, path, self)

        if options[:page]
          first_or_requested_page
        else
          last_page_number = first_or_requested_page.number_of_pages

          raw_other_pages_items = (2..last_page_number).to_a.map do |page|
            Array(Cubscout.connection.get(path, page: page, **options).body.dig("_embedded", path))
          end

          raw_all_pages = {
            "_embedded" => { path => (Array(raw_first_or_requested_page.dig("_embedded", path)) + raw_other_pages_items).flatten },
            "page" => {
              "number" => first_or_requested_page.page,
              "size" => first_or_requested_page.total_size,
              "totalPages" => first_or_requested_page.number_of_pages,
              "totalElements" => first_or_requested_page.total_size
            }
          }
          List.new(raw_all_pages, path, self)
        end
      end

      # used with an instance endpoint, get one instance of an Object
      # @param id [Integer] ID of the object to get
      # @param options [Hash] Optional query params described in Helspcout API documentation
      # @return [Object] Returns an instance of the class where the method is called.
      #   Example: +Foo.find(123) # => returns an instance of Foo+
      def find(id, options = {})
        raise Error, "`#{self}.find` method is not available" unless path

        self.new(Cubscout.connection.get("#{path}/#{id}", options).body)
      end
    end

    def self.included(mod)
      mod.extend ClassMethods
    end
  end
end
