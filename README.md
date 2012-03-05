# Webmaster Tools

* API very limited
* subset of tools
* based on mechanize

## Usage

Simple usage case to get error counts

```ruby
require 'webmaster_tools'

client = WebmasterTools.new(<username>, <password>)

pp client.crawl_error_counts(<url>)

```

## Interface

### crawl

#### info
#### errors
#### stats

### other

#### submit removal request


## Dependencies

Depends on [mechanize](http://mechanize.rubyforge.org/) to access the Webinterface


## Contributing

We'll check out your contribution if you:

- Provide a comprehensive suite of tests for your fork.
- Have a clear and documented rationale for your changes.
- Package these up in a pull request.

We'll do our best to help you out with any contribution issues you may have.


## License

The license is included as LICENSE in this directory.

