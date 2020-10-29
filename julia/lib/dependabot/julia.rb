# frozen_string_literal: true

# These all need to be required so the various classes can be registered in a
# lookup table of package manager names to concrete classes.
require "dependabot/julia/file_fetcher"
require "dependabot/julia/file_parser"
# require "dependabot/julia/update_checker"
# require "dependabot/julia/file_updater"
# require "dependabot/julia/metadata_finder"
# require "dependabot/julia/requirement"
# require "dependabot/julia/version"

require "dependabot/pull_request_creator/labeler"
Dependabot::PullRequestCreator::Labeler.
  register_label_details("julia", name: "julia", colour: "21ceff")  # TODO: colour

require "dependabot/dependency"
Dependabot::Dependency.register_production_check("julia", ->(_) { true })
