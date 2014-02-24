
require 'pp'
ARGV.each_with_index do |v,i|
  puts "ARGV[#{i}]:#{v.tainted?}"
end