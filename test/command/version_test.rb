require_relative '../test_helper'

module Command
  class VersionTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Command::VERSION
    end
  end
end
