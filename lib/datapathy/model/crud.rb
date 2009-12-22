
module Datapathy::Model
  module Crud

    extend ActiveSupport::Concern

    def save
      if new_record?
        create()
      else
        update()
      end
    end

    def create
      Datapathy::Collection.new(self).create
    end

    def update
      Datapathy::Collection.new(self).update(persisted_attributes)
    end

    def delete
      Datapathy::Collection.new(self).delete
    end

    module ClassMethods
      def create(*attributes)
        Datapathy::Collection.new(self, *attributes).create
      end

      def [](key)
        detect(self.key => key) || raise(Datapathy::RecordNotFound, "No #{model} found with #{self.key} `#{key}`")
      end

      def select(*attrs, &blk)
        query = Datapathy::Query.new(model)
        Datapathy::Collection.new(query).select(*attrs, &blk)
      end
      alias all select
      alias find_all select

      def detect(*attrs, &blk)
        select(*attrs, &blk).first
      end
      alias first detect
      alias find detect

      def update(attributes, &blk)
        select(&blk).update(attributes)
      end

      def delete(&blk)
        select(&blk).delete
      end

    end

  end

end
