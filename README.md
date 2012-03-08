# Webmaster Tools  [![](http://travis-ci.org/rngtng/webmaster_tools.png)](http://travis-ci.org/rngtng/webmaster_tools)

Webmaster Tools extends the official API to give programmatically access to various crawl information and functions which are available via the webinterface

The [Google Webmaster Tool API](http://code.google.com/apis/webmastertools/) is very limited and provides only a little subset of data available via the [webinterface](https://www.google.com/webmasters/tools/home?hl=en). By making use of mechanize, Webmaster Tools gives access to crawl_info, crawl_errors, crawl_stats and allows to submit url removal request (up to 1000 per day)


## Usage

Simple usage case to get error counts

```ruby
require 'webmaster_tools'

client = WebmasterTools.new(<username>, <password>)

pp client.crawl_error_counts(<url>)

```


## Dependencies

Depends on [mechanize](http://mechanize.rubyforge.org/) to access the webinterface


## Contributing

We'll check out your contribution if you:

- Provide a comprehensive suite of tests for your fork.
- Have a clear and documented rationale for your changes.
- Package these up in a pull request.

We'll do our best to help you out with any contribution issues you may have.


## License

The license is included as LICENSE in this directory.

