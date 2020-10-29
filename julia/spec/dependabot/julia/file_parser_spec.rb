# frozen_string_literal: true

require "spec_helper"
require "dependabot/julia/file_parser"

require_common_spec "file_parsers/shared_examples_for_file_parsers"

RSpec.describe Dependabot::Julia::FileParser do
  it_behaves_like "a dependency file parser"
end
