# frozen_string_literal: true

require "dependabot/file_fetchers"
require "dependabot/file_fetchers/base"

module Dependabot
  module Julia
    class FileFetcher < Dependabot::FileFetchers::Base
      def self.required_files_in?(filenames)
        filenames.include?("Project.toml")
      end

      def self.required_files_message
        "Repo must contain a Project.toml."
      end

      private

      def fetch_files
        fetched_files = []
        fetched_files << project_toml
        fetched_files << manifest_toml if manifest_toml
        fetched_files
      end

      def project_toml
        @project_toml ||= fetch_file_from_host("Project.toml")
      end

      def manifest_toml
        @manifest_toml ||= fetch_file_if_present("Manifest.toml")
      end
    end
  end
end

Dependabot::FileFetchers.register("julia", Dependabot::Julia::FileFetcher)
