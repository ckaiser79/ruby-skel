#!/usr/bin/env ruby

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rubygems'
require 'bundler/setup'

require '<%= @name %>'

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

