require 'jekyll-import/importers/drupal_common'

module JekyllImport
  module Importers
    class Drupal7 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.build_query(prefix, types)
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

      def self.aliases_query(prefix)
        "SELECT source, alias FROM #{prefix}url_alias WHERE source = ?"
      end

      def self.post_data(sql_post_data)
        content = sql_post_data[:body_value].to_s
        summary = sql_post_data[:body_summary].to_s
        tags = (sql_post_data[:tags] || '').downcase.strip

        data = {
          'excerpt' => summary,
          'categories' => tags.split('|')
        }

        return data, content
      end

    end
  end
end
