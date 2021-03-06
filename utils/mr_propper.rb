#!/usr/bin/env ruby

require 'rubygems'
require 'net/ssh'
require 'socket'
require 'optparse'
require 'systemu'
require 'require_all'

# Import custom classes
require_all './lib'

$work_dir=FileUtils.pwd

# Parse command line args
def parse_args
  options = {}
  optparse = OptionParser.new do|opts|
    # Set a banner
    opts.banner = "Usage: harness.rb [-c || --config ] FILE"

    options[:config] = nil
    opts.on( '-c', '--config FILE', 'Use configuration FILE' ) do|file|
      options[:config] = file
    end

    opts.on( '-h', '--help', 'Display this screen' ) do
      puts opts
      exit
    end
  end
  optparse.parse!
  return options
end

###################################
#  Main
###################################
# Parse commnand line args
options=parse_args
puts "Cleaning host is config #{options[:config]}" if options[:config]

# Read config file
config = YAML.load(File.read(File.join($work_dir,options[:config])))

TestWrapper.new(config).clean_hosts

