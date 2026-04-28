# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2026, by Samuel Williams.

def after_gem_release_version_increment(version)
	context["releases:update"].call(version)
	context["utopia:project:update"].call
end

def after_gem_release(tag:, **options)
	context["releases:github:release"].call(tag)
end