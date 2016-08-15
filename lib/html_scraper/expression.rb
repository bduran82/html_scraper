# frozen_string_literal: true
module HtmlScraper
  class Expression
    CODE_PLACEHOLDER = '$'

    def initialize(text)
      @text = text
    end

    def evaluate(text)
      result = {}
      if !variable_name.blank?
        result[variable_name.to_sym] = remove_newlines(evaluate_assignation(regexp_filter(text)))
      end
      return result
    end

    def regexp_filter(text)
      result = text
      if !regexp.blank?
        regexp_match = text.match(regexp)
        if !regexp_match.blank?
          result = regexp_match[0] 
        else
          result = ''
        end
      end
      return result
    end
    private :regexp_filter

    def evaluate_assignation(text)
      value = text
      eval(code.gsub(CODE_PLACEHOLDER, 'value'))
    rescue
      ''
    end
    private :evaluate_assignation

    def remove_newlines(text)
      return text.split(/[\n\t]/).map(&:strip).join(' ')
    end
    private :remove_newlines

    def variable_name
      return @variable_name ||= begin
        match_capture(1)
      end
    end
    private :variable_name

    def regexp
      return @regexp ||= begin
        regexp_match = match_capture(2)
        regexp_match[1..-2] unless regexp_match.blank?
      end
    end
    private :regexp

    def code
      return @code ||= begin
        code_match = match_capture(3)
        if !code_match.blank?
          code_match[1..-1]
        else
          CODE_PLACEHOLDER
        end
      end
    end
    private :code

    def match_capture(index)
      return match[index] unless match.blank?
      return nil
    end
    private :match_capture

    def match
      return @match ||= begin
        @text.match(%r{^\s*(\w+)(/.*/)?\s*(=.*)?\s*$})
      end
    end
    private :match
  end
end
