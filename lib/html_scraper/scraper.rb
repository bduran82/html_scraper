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
      return inspect(html_template.root, Nokogiri::HTML(html))
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
      return [
        evaluate_attributes(template_node, html_node),
        evaluate_text(template_node, html_node),
        template_node.children.map { |t_node| inspect(t_node, html_node) }.reduce({}, &:merge)
      ].reduce(&:merge)
    end
    private :parse_node

    def evaluate_attributes(template_node, html_node)
      return template_node.attributes.map do |name, attr|
        evaluate_expressions(attr.value, html_node.attributes[name]&.value)
      end.reduce({}, &:merge)
    end
    private :evaluate_attributes

    def evaluate_text(template_node, html_node)
      return evaluate_expressions(template_node.xpath('./text()').text, html_node.text)
    end
    private :evaluate_text

    def evaluate_expressions(expression, text)
      result = expression.scan(expr_regexp).flatten.reduce({}) do |res, expr|
        res.merge(Expression.new(expr).evaluate(text))
      end

      return result
    end
    private :evaluate_expressions

    def build_xpath(template_node)
      xpath = ".//#{template_node.name}"
      attributes = template_node.attributes.reject do |name, attr|
        name.start_with?('hs-') || attr.value =~ expr_regexp
      end
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

    def expr_regexp
      /^\s*{{(.*)}}\s*$/
    end
    private :expr_regexp

    def log(text)
      puts "#{'   ' * @depth}#{text}" if @verbose
    end
  end
end
