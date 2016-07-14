require 'jekyll-import/importers/drupal_common'

module JekyllImport
  module Importers
    class Drupal6 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.build_query(prefix, types)
        types = types.join("' OR n.type = '")
        types = "n.type = '#{types}'"

        query = <<EOS
                SELECT n.nid,
                       n.title,
                       nr.body,
                       nr.teaser,
                       n.created,
                       n.status,
                       n.type,
                       GROUP_CONCAT( td.name SEPARATOR '|' ) AS 'tags'
                FROM #{prefix}node_revisions AS nr,
                     #{prefix}node AS n
                     LEFT OUTER JOIN #{prefix}term_node AS tn ON tn.nid = n.nid
                     LEFT OUTER JOIN #{prefix}term_data AS td ON tn.tid = td.tid
                WHERE (#{types})
                  AND n.vid = nr.vid
                GROUP BY n.nid
EOS

        return query
      end

      def self.aliases_query(prefix)
        "SELECT src AS source, dst AS alias FROM #{prefix}url_alias WHERE src = ?"
      end

      def self.post_data(sql_post_data)
        content = sql_post_data[:body].to_s
        summary = sql_post_data[:teaser].to_s
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
