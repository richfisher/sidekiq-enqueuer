# Sidekiq::Enqueuer

A Sidekiq Web extension to enqueue/schedule job in Web UI. Support both Sidekiq::Worker and ActiveJob.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-enqueuer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-enqueuer

## Usage

* Open Sidekiq Web, click the Enqueuer tab.

* You can see a list of job classes/modules and params. Click Enqueue Form.

![list](https://cloud.githubusercontent.com/assets/830633/14494297/c9b01b10-01bc-11e6-8ef5-a4d29ff45fb3.png)

* Fill the form, click Enqueue or Schedule.  
![form](https://cloud.githubusercontent.com/assets/830633/14494314/ddd9f8ae-01bc-11e6-86ce-0641a9c4d3e4.png)

* That is it!

## Form filling
* Support string value and hash value. Value will be stripped.
* Start with { will be parsed by YAML as hash, eg: {k1: v1, k2: v2} to {'k1'=> 'v1', 'k2'=> 'v2'}


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/richfisher/sidekiq-enqueuer.

