env :PATH, ENV['PATH']

set :output, 'log/cron.log'

every 8.minutes do
  rake 'auto_book'
end
