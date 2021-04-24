# frozen_string_literal: true

require "jekyll-import/importers/drupal_common"

module JekyllImport
  module Importers
    class Drupal6 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.build_query(prefix, types, _engine)
        types = types.join("' OR n.type = '")
        types = "n.type = '#{types}'"

        query = <<SQL
                SELECT n.nid,
                       n.title,
                       nr.body,
                       nr.teaser,
                       n.created,
                       n.status,
                       ua.dst AS alias,
                       n.type,
                       GROUP_CONCAT( td.name SEPARATOR '|' ) AS 'tags'
                FROM #{prefix}node_revisions AS nr, url_alias AS ua,
                     #{prefix}node AS n
                     LEFT OUTER JOIN #{prefix}term_node AS tn ON tn.nid = n.nid
                     LEFT OUTER JOIN #{prefix}term_data AS td ON tn.tid = td.tid
                WHERE (#{types})
                  AND n.vid = nr.vid
                  AND  ua.src = CONCAT( 'node/', n.nid)
                GROUP BY n.nid, ua.dst
SQL

        query
      end

      def self.aliases_query(prefix)
        "SELECT src AS source, dst AS alias FROM #{prefix}url_alias WHERE src = ?"
      end

      def self.post_data(sql_post_data)
        content = sql_post_data[:body].to_s
        summary = sql_post_data[:teaser].to_s
        tags = (sql_post_data[:tags] || "").downcase.strip

        data = {
          "excerpt"    => summary,
          "categories" => tags.split("|").uniq,
        }

        data["permalink"] = "/" + sql_post_data[:alias] if sql_post_data[:alias]

        [data, content]
      end
    end
  end
end
