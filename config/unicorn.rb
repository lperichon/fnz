worker_processes 3
timeout 30

preload_app true

#@resque_pid = nil

#before_fork do |server, worker|
#  @resque_pid ||= spawn("bundle exec rake " + \
#  "resque:work QUEUES=uploader,mailer")
#end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection 
  end
end