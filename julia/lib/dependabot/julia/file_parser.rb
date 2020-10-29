# frozen_string_literal: true

require "toml-rb"

require "dependabot/dependency"
require "dependabot/file_parsers"
require "dependabot/file_parsers/base"

module Dependabot
  module Julia
    class FileParser < Dependabot::FileParsers::Base
      require "dependabot/file_parsers/base/dependency_set"

      def parse
        dependency_set = DependencySet.new
        dependency_set += all_projects_dependencies
        dependency_set.dependencies
      end

      private

      def check_required_files
        raise "No Project.toml!" if project_files.none?
      end

      def all_projects_dependencies
        dependencies = DependencySet.new
        project_files.each do |file|
          dependencies += project_dependencies(file)
        end
        dependencies
      end

      def project_dependencies(file)
        project = parsed_file(file)
        deps = project["deps"] || {}
        compat = project["compat"] || {}
        dependencies = DependencySet.new
        deps.each do |dep, uuid|
          dependencies << Dependency.new(
            name: dep,
            package_manager: "julia",
            requirements: [{
              requirement: canonicalize_compat(compat[dep]),
              file: file.name,
              groups: [],
              source: nil,
              metadata: {
                uuid: uuid
              }
            }]
          )
        end
        dependencies
      end

      def canonicalize_compat(compat)
        compat = compat.strip
        compat = "^#{compat}" if compat.start_with?(/\d/)
        compat
      end

      def project_files
        dependency_files.select { |file| file.name == "Project.toml" }
      end

      def parsed_file(file)
        @parsed_files ||= {}
        @parsed_files[file.name] ||= TomlRB.parse(file.content)
      rescue TomlRB::ParseError, TomlRB::ValueOverwriteError
        raise Dependabot::DependencyFileNotParseable, file.path
      end
    end
  end
end

Dependabot::FileParsers.register("julia", Dependabot::Julia::FileParser)
