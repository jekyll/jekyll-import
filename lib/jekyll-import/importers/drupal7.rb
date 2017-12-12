require "jekyll-import/importers/drupal_common"

module JekyllImport
  module Importers
    class Drupal7 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.build_query(prefix, types, engine)
        types = types.join("' OR n.type = '")
        types = "n.type = '#{types}'"

        if engine == "postgresql"
          tag_group = "STRING_AGG(td.name, '|')"
        else
          tag_group = "GROUP_CONCAT(td.name SEPARATOR '|')"
        end

        query = <<EOS
                SELECT n.nid,
                       n.title,
                       fdb.body_value,
                       fdb.body_summary,
                       n.created,
                       n.status,
                       n.type,
                       (SELECT #{tag_group} FROM taxonomy_term_data td, taxonomy_index ti WHERE ti.tid = td.tid AND ti.nid = n.nid) AS 'tags'
                FROM #{prefix}node AS n
                LEFT JOIN #{prefix}field_data_body AS fdb ON fdb.entity_id = n.nid AND fdb.entity_type = 'node'
                WHERE (#{types})
EOS

        return query
      end

      def self.aliases_query(prefix)
        "SELECT source, alias FROM #{prefix}url_alias WHERE source = ?"
      end

      def self.post_data(sql_post_data)
        content = sql_post_data[:body_value].to_s
        summary = sql_post_data[:body_summary].to_s
        tags = (sql_post_data[:tags] || "").downcase.strip

        data = {
          "excerpt"    => summary,
          "categories" => tags.split("|"),
        }

        return data, content
      end
    end
  end
end
