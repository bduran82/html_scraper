# HtmlScraper

HtmlScraper is a ruby gem that simply parses a html document to a json structure following a template

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'html_scraper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install html_scraper

## Usage

### Simple html parsing

Expressions sourrounded by `{{ }}` will be parsed as simple json attributes:

```ruby
template = '
  <div id="people-list">
    <div class="person" hs-repeat="people">
      <a href="{{ link }}">{{ surname }}</a>
      <p>{{ name }}</p>
    </div>
  </div>
'
html = '
    <html>
      <body>
          <div id="people-list">
          <div class="person">
            <a href="/clint-eastwood">Eastwood</a>
            <p>Clint</p>
          </div>
      </body>
    </html>
 '
 json = HtmlScraper::Scraper.new(template: template).parse(html)
```

The json result:

```
{:surname=>"Eastwood", :name=>"Clint", :link=>"/clint-eastwood"}
```

### Iterative data

To parse iterative structures define the attribute `hs-repeat` to the html node containing the iteration:

```ruby
template = '
  <div id="people-list">
    <div class="person" hs-repeat="people">
      <h5>{{ surname }}</h5>
      <p>{{ name }}</p>
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
      </div>
      <div class="person">
        <h5>Woods</h5>
        <p>James</p>
      </div>
      <div class="person">
        <h5>Kinski</h5>
        <p>Klaus</p>
      </div>
    </div>
  </body>
  </html>
'
json = HtmlScraper::Scraper.new(template: template).parse(html)
```

The json result:

```ruby
{:people=>
  [{:surname=>"Eastwood", :name=>"Clint"},
   {:surname=>"Woods", :name=>"James"},
   {:surname=>"Kinski", :name=>"Klaus"}]}
```

### Expression parsing

Regular expressions can be used within the `{{ }}` expression next to the attribute name (surrounded by //):

```ruby
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
```

will result in:


```
{:surname=>"Eastwood", :name=>"Clint", :birthday=>"31.05.1930"}
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bduran82/html_scraper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

