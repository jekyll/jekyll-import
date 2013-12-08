module JekyllImport
  class Importer
    def self.inherited(base)
      subclasses << base
    end

    def self.subclasses
      @subclasses ||= []
    end

    def self.stringify_keys(hash)
      the_hash = hash.clone
      the_hash.keys.each do |key|
        the_hash[(key.to_s rescue key) || key] =  the_hash.delete(key)
      end
      the_hash
    end

    def self.run(options = {})
      options = stringify_keys(options)
      self.require_deps
      self.validate(options) if self.respond_to?(:validate)
      self.process(options)
    end
  end
end
