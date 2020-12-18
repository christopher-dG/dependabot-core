# frozen_string_literal: true

require "dependabot/clients/github_with_retries"
require "dependabot/update_checkers"
require "dependabot/update_checkers/base"
require "dependabot/julia/version"

module Dependabot
  module Julia
    class UpdateChecker < Dependabot::UpdateCheckers::Base
      GENERAL = "JuliaRegistries/General"

      def updated_requirements
        # New requirements after updating.
      end

      def latest_version
        return if path_dependency?
        versions = package_versions(dependency.requirements.first.metadata.uuid)
        versions.max_by { |ver| Version.new ver }
      end

      def latest_resolvable_version
        # The newest version of this dep that resolves, ignoring this dep's compat.
        return if path_dependency?
      end

      def latest_resolvable_version_with_no_unluck
        # The newest version of this dep that resolves, considering this dep's compat.
        return if path_dependency?
      end

      def latest_resolvable_version_with_full_unlock?
        false
      end

      def updated_dependencies_after_full_unlock
        raise NotImplementedError
      end

      def path_dependency?
        dependency_type?("path")
      end

      def git_dependency?
        dependency_type?("git")
      end

      def dependency_type?(type)
        sources = dependency.requirements.map { |r| r.source || {} }
        sources.any? { |s| s && s[:type] == type }
      end

      def versions(uuid)
        versions_toml(uuid).keys
      end

      def registry_toml
        return @registry_toml if @registry_toml
        contents = github.contents(GENERAL, path: "Registry.toml")
        @registry_toml ||= TomlRB.parse(Base64.decode64(contents.content))
      end

      def versions_toml(uuid)
        @versions_toml ||= {}
        path = registry_toml["packages"][uuid]["path"]
        return @versions_toml[path] if @versions_toml[path]
        contents = github.contents(GENERAL, path: "#{path}/Versions.toml")
        @versions_toml[path] ||= TomlRB.parse(Base64.decode64(contents.content))
      end

      def github
        GithubWithRetries.for_github_dot_com(credentials)
      end
    end
  end
end

Dependabot::UpdateCheckers.register("julia", Dependabot::Julia::UpdateChecker)
