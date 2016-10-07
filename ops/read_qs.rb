require 'sidekiq/api'

mailer=Sidekiq::Queue.new("mailers")
puts "Current queue size: " + mailer.size.to_s

mailer.each do |job|
  puts "+ Job: " + job.klass  + " Args: " + job.args 
end
