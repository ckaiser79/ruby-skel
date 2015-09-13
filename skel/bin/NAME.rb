
require 'rubygems'
require 'bundler/setup'

class Main
  def initialize argv


    @options = {}

    argv << "-h" if argv.empty?

    p = OptionParser.new do |opts|
      opts.banner = "Usage: <%= @name %> [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
      end

      opts.on("-h", "--help", "Show this message") do |v|
        puts opts
        exit 2
      end

    end

    begin
      p.parse! argv
    rescue => e
      puts p
      puts e
      exit 2
    end

  end

  def run
    puts @options
    puts ARGV
  end
end

Main.new(ARGV).run

