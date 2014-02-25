require 'rubygems'
require 'inline'

class DeSafe
   inline do |builder|
     builder.prefix "RUBY_EXTERN int ruby_safe_level;"

     builder.c <<-EOC
       static void
       reduce() {
         ruby_safe_level = 0;
       }
     EOC
   end
end


$SAFE = ARGV.shift.to_i rescue 0

p $SAFE

DeSafe.new.reduce

p $SAFE