module JekyllImport
  class Importer
    def self.inherited(base)
      p base
      subclasses << base
    end

    def self.subclasses
      @subclasses ||= []
    end
  end
end
