module Cubscout
  # the List class is the base class for any collection of objects retrieved from the Helpscout API.
  # it's an Enumerable that can iterate over each of it's items.
  #
  # Helpscout API V2 is paginated and will return at max 50 items for each collection
  # endpoint. The List class allows to query the page status.
  class List
    include Enumerable

    def initialize(raw_payload, collection_name, object_class)
      @raw_payload = raw_payload
      @collection_name = collection_name
      @object_class = object_class
    end

    # current page number
    def page
      raw_payload.dig("page", "number")
    end

    # number of items in the current page. Should be the same as number of +items+, but sometimes it's not (assumption: it's a bug in helpscout)
    def page_size
      raw_payload.dig("page", "size")
    end

    # total number of pages available
    def number_of_pages
      raw_payload.dig("page", "totalPages")
    end

    # total number of items available
    def total_size
      raw_payload.dig("page", "totalElements")
    end

    # array of objects Object retrieved from the API's collection endpoint.
    def items
      Array(raw_payload.dig("_embedded", collection_name)).map { |item| object_class.new(item) }
    end

    # number of +items+
    def size
      items.size
    end

    def each(&block)
      items.each(&block)
    end

    private

    attr_reader :raw_payload, :collection_name, :object_class
  end
end
