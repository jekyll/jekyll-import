# frozen_string_literal: true

require "jekyll-import/importers/drupal_common"

module JekyllImport
  module Importers
    class Drupal7 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.build_query(prefix, types, engine)
        types = types.join("' OR n.type = '")
        types = "n.type = '#{types}'"

        tag_group = if engine == "postgresql"
                      <<POSTGRESQL
            (SELECT STRING_AGG(td.name, '|')
            FROM #{prefix}taxonomy_term_data td, #{prefix}taxonomy_index ti
            WHERE ti.tid = td.tid AND ti.nid = n.nid) AS tags
POSTGRESQL
                    else
                      <<SQL
            (SELECT GROUP_CONCAT(td.name SEPARATOR '|')
            FROM #{prefix}taxonomy_term_data td, #{prefix}taxonomy_index ti
            WHERE ti.tid = td.tid AND ti.nid = n.nid) AS 'tags'
SQL
                    end

        query = <<QUERY
                SELECT n.nid,
                       n.title,
                       fdb.body_value,
                       fdb.body_summary,
                       n.created,
                       n.status,
                       n.type,
                       #{tag_group}
                FROM #{prefix}node AS n
                LEFT JOIN #{prefix}field_data_body AS fdb
                  ON fdb.entity_id = n.nid AND fdb.entity_type = 'node'
                WHERE (#{types})
QUERY

        query
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

        [data, content]
      end
    end
  end
end
