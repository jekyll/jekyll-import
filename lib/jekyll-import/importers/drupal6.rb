require 'jekyll-import/importers/drupal_common.rb'

module JekyllImport
  module Importers
    class Drupal6 < Importer
      include DrupalCommon
      extend DrupalCommon::ClassMethods

      def self.get_query(prefix, types)
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

      def self.get_aliases_query(prefix)
        return "SELECT src AS source, dst AS alias FROM #{prefix}url_alias WHERE src = ?"
      end

      def self.get_data(post)
        content = post[:body].to_s
        summary = post[:teaser].to_s
        tags = (post[:tags] || '').downcase.strip

        data = {
          'excerpt' => summary,
          'categories' => tags.split('|')
        }

         return data, content
      end

    end
  end
end
