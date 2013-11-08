module JekyllImport
  class Importer
    def self.inherited(base)
      p base
      subclasses << base
      subclasses.sort!
    end

    def self.subclasses
      @subclasses ||= []
    end
  end
end
