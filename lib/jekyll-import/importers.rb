module JekyllImport
  module Importers
    Dir[File.dirname(__FILE__)].each do |f|
      require f
    end
  end
end
