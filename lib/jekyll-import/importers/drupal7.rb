require 'jekyll-import/importers/drupal_common.rb'

module JekyllImport
  module Importers
    class Drupal7 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.get_query(prefix, types)
        types = types.join("' OR n.type = '")
        types = "n.type = '#{types}'"

        query = <<EOS
                SELECT n.nid,
                       n.title,
                       fdb.body_value,
                       fdb.body_summary,
                       n.created,
                       n.status,
                       n.type,
                       GROUP_CONCAT( td.name SEPARATOR '|' ) AS 'tags'
                FROM #{prefix}field_data_body AS fdb,
                     #{prefix}node AS n
                     LEFT OUTER JOIN #{prefix}taxonomy_index AS ti ON ti.nid = n.nid
                     LEFT OUTER JOIN #{prefix}taxonomy_term_data AS td ON ti.tid = td.tid
                WHERE (#{types})
                  AND n.nid = fdb.entity_id
                  AND n.vid = fdb.revision_id
                GROUP BY n.nid"
EOS

        return query
      end

      def self.get_aliases_query(prefix)
        return "SELECT source, alias FROM #{prefix}url_alias WHERE source = ?"
      end

      def self.get_data(post)
        content = post[:body_value].to_s
        summary = post[:body_summary].to_s
        tags = (post[:tags] || '').downcase.strip

        data = {
          :excerpt => summary,
          :categories => tags.split('|')
        }

        return data, content
      end

    end
  end
end
