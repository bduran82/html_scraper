require 'test_helper'

class HtmlScraperTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::HtmlScraper::VERSION
  end
end
