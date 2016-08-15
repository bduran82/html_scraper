# frozen_string_literal: true
require 'nokogiri'

module HtmlScraper
  class Scraper
    def initialize(template:, verbose: false)
      @template = template
      @depth = 0
      @verbose = verbose
    end

    def parse(html)
      html_template = Nokogiri::HTML(@template)
      return {} if html_template.root.nil?
      template_root = html_template.root.children.first
      html_root = Nokogiri::HTML(html).root
      return inspect(template_root, html_root)
    end

    def inspect(template_node, html_node)
      result = {}
      tnode_xpath = build_xpath(template_node)
      matching_nodes = html_node.xpath(tnode_xpath)
      log("START #{tnode_xpath}...")
      @depth += 1
      sub_results = matching_nodes.map { |node| parse_node(template_node, node) }
      @depth -= 1
      log("END #{tnode_xpath}: #{sub_results.size} matches")

      if !template_node.attribute('hs-repeat').blank?
        result[template_node.attribute('hs-repeat').value.to_sym] = sub_results
      else
        result.merge!(sub_results.reduce({}, &:merge))
      end
      return result
    end

    def parse_node(template_node, html_node)
      expression = template_node.xpath('./text()').text
      result = evaluate_expressions(expression, html_node.text)
      children_results = template_node.children.map { |t_node| inspect(t_node, html_node) }
      return result.merge(children_results.reduce(&:merge))
    end
    private :parse_node

    def evaluate_expressions(expression, text)
      result = expression.scan(/^\s*{{(.*)}}\s*$/).flatten.reduce({}) do |res, expr|
        res.merge(Expression.new(expr).evaluate(text))
      end

      return result
    end
    private :evaluate_expressions

    def build_xpath(template_node)
      xpath = ".//#{template_node.name}"
      attributes = template_node.attributes.reject { |k, _| k.start_with?('hs-') }
      if !attributes.blank?
        selector = attributes.map { |k, v| attribute_selector(k, v) }.join
        xpath = "#{xpath}#{selector}"
      end
      return xpath
    end
    private :build_xpath

    def attribute_selector(key, value)
      selector = if key == 'class'
                   "contains(@#{key}, '#{value}')"
                 else
                   "@#{key}='#{value}'"
                 end
      return "[#{selector}]"
    end
    private :attribute_selector

    def log(text)
      puts "#{'   ' * @depth}#{text}" if @verbose
    end
  end
end
