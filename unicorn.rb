if ENV['RACK_ENV'] == 'production'
  worker_processes 4 # amount of unicorn workers to spin up
else
  worker_processes 1 # amount of unicorn workers to spin up
end
timeout 60         # restarts workers that hang for 30 seconds
