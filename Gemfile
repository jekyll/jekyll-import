# frozen_string_literal: true

source "https://rubygems.org"
gemspec

gem "jekyll", ENV["JEKYLL_VERSION"] if ENV["JEKYLL_VERSION"]
gem "kramdown-parser-gfm" if ENV["JEKYLL_VERSION"] == "~> 3.9"

# Psych 5 has stopped bundling `libyaml` and expects it to be installed on the host system prior to
# being invoked.
# Since we don't have a direct dependency on the Psych gem (it gets included in the gem bundle as a
# dependency of the `rdoc` gem), lock psych gem to v4.x instead of installing `libyaml` in our
# development / CI environment.
gem "psych", "~> 4.0"

gem "test-unit"
