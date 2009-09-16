module Datapathy::Adapters

  # Adapters should extend this class, and implement the 4 CRUD methods:
  #   create, read, update and delete.
  #
  # Convention has established the following terminology:
  #
  #   * resource - an instance of a model
  #   * record   - a non-model object (often a Hash) representing the data
  #                in a model. This is usually what comes out of the data-store.
  #   
  class AbstractAdapter

    def initialize(options = {})
      @options = options

    end

    # Writes resources to the data-store. 
    #
    # @param [Enumerable<Resource>] resources
    #   The list of resources to be created
    #
    # @return [Enumerable<Resource>]
    #   The resources that were created. Some data-stores are able to update the
    #   resources, (for example, a Serial column in an RDBMS), and these attributes
    #   should be updated directly on the resources and returned.
    def create(resources)
      raise NotImplementedError, "#{self.class}#create not implemented"
    end

    # Retrieves records from the data-store
    #
    # @param [Datapathy::Query] query
    #   A Query object representing the search to be performed. It is also capable of
    #   filtering the records if the adapter does not have the facilty to do so. See
    #   MemoryAdapter for an example of this.
    #
    # @return [Hash]
    #   The records resulting from the retrieval. The keys of the hash MUST be symbols
    #   identical to the names of the attributes of the models.
    def read(query)
      raise NotImplementedError, "#{self.class}#read not implemented"
    end

    # Updates one or many existing resources in the data-store
    #
    # @param [Hash] attributes
    #   The attributes to update the resources with, the attribute names being
    #   symbol keys in the hash.
    #
    # @param [Datapathy::Query | Datapathy::Collection]
    #   The second parameter is either a query that selects the records to be
    #   updated, or a collection of the records themselves. The first case is 
    #   useful for performing bulk-updates without having to read the records 
    #   from the data-store. 
    #
    # @return []
    def update(attributes, query_or_collection)
      raise NotImplementedError, "#{self.class}#update not implemented"
    end

    # Deletes existing resources
    def delete(query_or_collection)
      raise NotImplementedError, "#{self.class}#delete not implemented"
    end

  end

end

