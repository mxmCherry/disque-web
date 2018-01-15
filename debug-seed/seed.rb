require 'disque'

addrs = ENV['DISQUE_ADDRS']
raise 'No DISQUE_ADDRS provided' unless addrs && addrs.length > 0

c = Disque.new addrs

5.times do |i|
  queue = "queue-#{i}"
  puts "seeding queue #{queue}"

  20.times do |j|
    job = %Q'{ "job": #{j} }'
    puts "  seeding job #{job}"

    c.push queue, job, 10000
  end
end
