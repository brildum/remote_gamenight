app: RACK_ENV=development rackup
scheduler: RACK_ENV=development ruby scheduler.rb
workers: RACK_ENV=development QUEUE=slack_hook INTERVAL=0.1 rake resque:work
