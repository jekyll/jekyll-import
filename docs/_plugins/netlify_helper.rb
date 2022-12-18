# frozen_string_literal: true

# The Liquid templates for this site currently renders absolute URLs to various subpages, which
# interferes with Netlify's "Deploy Preview" for pull requests containing changes to the docs-site.
#
# Therefore, override `{{ site.url }}` with the Netlify Deploy Preview URL for seamless navigation
# during review.
#
# ref: https://docs.netlify.com/configure-builds/environment-variables/#deploy-urls-and-metadata
#
# DELETE THIS PLUGIN once the templates start rendering relative URLs to the subpages.

return unless ENV["NETLIFY"]
return if ENV["DEPLOY_PRIME_URL"].to_s.empty?

Jekyll::Hooks.register :site, :after_init do |site|
  site.config["url"] = ENV["DEPLOY_PRIME_URL"]
end
