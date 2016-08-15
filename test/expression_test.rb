# frozen_string_literal: true
require 'test_helper'

class ExpressionTest < Minitest::Test
  def test_simple_assignation
    expression = HtmlScraper::Expression.new('title')
    assert_equal 'A simple title', expression.evaluate('A simple title')[:title]
  end

  def test_regexp
    expression = HtmlScraper::Expression.new('person/[^\(]+/')
    assert_equal 'John Smith', expression.evaluate('John Smith (1980)')[:person]
  end

  def test_evaluate
    expr = 'date=begin m=$.match(/([0-9]{2}\.[0-9]{2})([0-9]{4}).*(..:..)/) ; "#{m[1]}.#{m[2]} #{m[3]}" end'
    expression = HtmlScraper::Expression.new(expr)
    result = expression.evaluate('16.062016Monday 20:00')
    assert_equal '16.06.2016 20:00', result[:date]
  end
end
