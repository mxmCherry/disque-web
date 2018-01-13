require 'disque'

c = Disque.new ENV['DISQUE_ADDRS']

5.times do |i|
  20.times do |j|
    c.push "queue-#{i}", %Q'{ "job": #{j} }', 10000
  end
end
