lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ci'

logger = Logger.new(STDOUT)

# thanks integrity!
def ansi_color_codes(string)
  string.gsub("\e[0m", '</span>').
    gsub(/\e\[(\d+)m/, "<span class=\"color\\1\">")
end

first_result = nil
f = Thread.new do
  command = CI::Command.new(logger)
  command.cd "~/Development/mailmask-ruby" do
    first_result = command.run "rspec" do |chunk|
      print ansi_color_codes(chunk)
    end
  end
end

second_result = nil
s = Thread.new do
  command = CI::Command.new(logger)
  command.cd "~/Development/mailmask" do
    second_result = command.run "bundle exec rake" do |chunk|
      print ansi_color_codes(chunk)
    end
  end
end

command = CI::Command.new(logger)
t = Thread.new do
  command = CI::Command.new(logger)
  command.cd "~/Development/mailmask" do
    third_result = command.run %{echo "\e[31mHello Stackoverflow\e[0m"} do |chunk|
      print ansi_color_codes(chunk)
    end
  end
end

[ f, s, t ].each &:join
# [ f ].each &:join

require 'rubygems'
require 'bcat'

File.open('test.html', 'w+') do |f|
  f.write Bcat::ANSI.new(first_result.output).to_html
end
