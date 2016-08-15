# frozen_string_literal: true
require 'test_helper'

class ScraperTest < Minitest::Test
  def test_parse
    template = '
      <html>
        <body>
          <div id="people-list">
            <div class="person" hs-repeat="people">
              <a href="{{ link }}">{{ surname }}</a>
              <p>{{ name }}</p>
            </div>
          </div>
        </body>
      </html>
    '

    html = '
      <html>
      <body>
        <div id="people-list">
          <div class="person">
            <a href="/clint-eastwood">Eastwood</a>
            <p>Clint</p>
          </div>
          <div class="person">
            <a href="/james-woods">Woods</a>
            <p>James</p>
          </div>
          <div class="person">
            <a href="/klaus-kinski">Kinski</a>
            <p>Klaus</p>
          </div>
        </div>
      </body>
      </html>
    '
    result = HtmlScraper::Scraper.new(template: template).parse(html)
    assert_equal 3, result[:people].size, 'Iterative patterns should have been parsed'
    assert_equal 'Eastwood', result[:people].first[:surname], 'Array element details should have been parsed'
    assert_equal 'Clint', result[:people].first[:name], 'Array element details should have been parsed'
    assert_equal '/clint-eastwood', result[:people].first[:link], 'Node attributes should have been parsed'
  end

  def test_parse_regexp
    template = '<div id="people-list">
      <div class="person">
        <h5>{{ surname }}</h5>
        <p>{{ name }}</p>
        <span>{{ birthday/\d+\.\d+\.\d+/ }}</span>
      </div>
    </div>
    '

    html = '
      <html>
        <body>
            <div id="people-list">
            <div class="person">
              <h5>Eastwood</h5>
              <p>Clint</p>
              <span>Born on 31.05.1930</span>
            </div>
        </body>
      </html>
   '
   json = HtmlScraper::Scraper.new(template: template).parse(html)
   assert_equal '31.05.1930', json[:birthday], 'Attribute regexp should be parsed'
  end

  def test_text_parsing
    template = '
      <table id="list">
        <tr hs-repeat="events">
          <td class="date">{{ date=begin m=$.match(/([0-9]{2}\.[0-9]{2})([0-9]{4}).*(..:..)/) ; m.present? ? "#{m[1]}.#{m[2]} #{m[3]}" : "" end }}</td>
          <td class="details">
             <span class="name">{{ title }}</span>
             <span class="description">{{ description }}</span>
          </td>
        </tr>
      </table>
    '

    html = '
      <table id="list" cellpadding="0" cellspacing="0">
        <tbody>
           <tr class="odd">
             <td class="date"><span class="day-month">16.06</span><span class="year">2016</span><span class="dayname">Thu</span> <samp class="time">21:00</samp></td>
             <td class="details">
               <span class="name">20th Anniversary</span>
               <span class="description">Party with free food and drinks</span>
            </td>
           </tr>
           <tr class="even">
             <td class="date"><span class="day-month">17.06</span><span class="year">2016</span><span class="dayname">Fri</span> <samp class="time">20:00</samp></td>
             <td class="details">
               <span class="name">Beer tasting</span>
               <span class="description">The best craft beers</span>
            </td>
           </tr>
           <tr class="odd">
             <td class="date"><span class="day-month">18.06</span><span class="year">2016</span><span class="dayname">Sat</span> <samp class="time">19:00</samp></td>
             <td class="details">
               <span class="name">Weekly quiz</span>
               <span class="description">Pub quiz about everything</span>
            </td>
           </tr>
        </tbody>
     </table>
    '

    result = HtmlScraper::Scraper.new(template: template).parse(html)
    assert_equal 3, result[:events].size
    event = result[:events].first
    assert_equal '20th Anniversary', event[:title], 'Text should be stripped and in one line'
    assert_equal 'Party with free food and drinks', event[:description], 'Text should be stripped and in one line'
    assert_equal '16.06.2016 21:00', event[:date], 'Text assgination expressions should be evaluated'
  end
end
