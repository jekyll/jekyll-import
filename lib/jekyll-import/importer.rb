module JekyllImport
  class Importer
    def self.inherited(base)
      subclasses << base
    end

    def self.subclasses
      @subclasses ||= []
    end

    def self.run(options = {})
      self.require_deps
      self.validate(options) if self.respond_to?(:validate)
      self.process(options)
    end
  end
end
