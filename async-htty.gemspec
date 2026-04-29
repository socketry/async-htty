# frozen_string_literal: true

require_relative "lib/async/htty/version"

Gem::Specification.new do |spec|
	spec.name = "async-htty"
	spec.version = Async::HTTY::VERSION
	
	spec.summary = "An Async server runtime for HTTY sessions that carry HTTP/2 over terminal side channels."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.cert_chain  = ["release.cert"]
	spec.signing_key = File.expand_path("~/.gem/release.pem")
	
	spec.homepage = "https://github.com/socketry/async-htty"
	
	spec.metadata = {
		"documentation_uri" => "https://socketry.github.io/async-htty/",
		"source_code_uri" => "https://github.com/socketry/async-htty.git",
	}
	
	spec.files = Dir.glob(["{examples,lib,test}/**/*", "*.md"], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.3"
	
	spec.add_dependency "async", "~> 2.39"
	spec.add_dependency "async-http", "~> 0.88"
	spec.add_dependency "protocol-http", "~> 0.62"
	spec.add_dependency "protocol-htty", "~> 0.2"
end
