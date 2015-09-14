#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'find'
require 'optparse'
require 'fileutils'
require 'erb'

class MergeController

  attr_accessor :name

  #
  # foo-bar-aBc become FooBarAbc
  #
  def toCamelCase name
    a = name.split /-/
    r = ''

    a.each do |item|
      r += item.capitalize
    end

    r
  end

  def index
    @nameOfModule = toCamelCase @name
  end

  def getBinding # this is only a helper method to access the objects binding method
    binding
  end
end

class Main
  def initialize argv

    @options = {}

    argv << "-h" if argv.empty?

    p = OptionParser.new do |opts|
      opts.banner = %{
Usage: set-name.rb [options]
Create a project skeleton for ruby projects
      }

      opts.on("-v", "--[no-]verbose", "run verbosely") do |v|
        @options[:verbose] = v
      end

      @options[:name] = 'default'
      opts.on("-n", "--name NAME", "name of project [" + @options[:name] + "]") do |v|
        @options[:name] = v
      end

      @options[:merge] = true
      opts.on("-e", "--[no-]merge", "merge of textfiles after copy, default true") do |v|
        @options[:merge] = v
      end

      @options[:rename] = true
      opts.on("-r", "--[no-]rename", "rename files after copy, default true") do |v|
        @options[:rename] = v
      end

      @options[:targetdir] = 'target'
      opts.on("-t", "--target DIR", "directory where files should be copied to") do |v|
        @options[:targetdir] = v
      end

      @options[:skeldir] = './skel'
      opts.on("-s", "--skel DIR", "Directory where files are located") do |v|
        @options[:skeldir] = v
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
    #
    # 1. copy all files to new directory
    # 2. rename the files with NAME in it
    # 3. replace variables in files
    #

    FileUtils.mkdir_p @options[:targetdir]
    FileUtils.cp_r @options[:skeldir] + '/.', @options[:targetdir]


    files = findFilesNeedsRenaming
    files.each do |file|
      renameFile file
    end


    findAndMergeTemplates

  end

  private

  def renameFile file

    match = /(.*)(NAME)(.*)/.match file

    if not match.nil?

      newFileName = match[1] + @options[:name] + match[3]

      log :info, "rename " + file.to_s + " to " + newFileName
      begin
        FileUtils.mv file, newFileName if @options[:rename]
      rescue => e
        log :warn, e
      end


    end

  end

  def findFilesNeedsRenaming
    files = []

    Find.find @options[:targetdir] do |file|
      files.push file if file.include? 'NAME'
    end

    files.reverse
  end

  def findAndMergeTemplates
    Find.find @options[:targetdir] do |file|
      mergeTemplate file if textfile? file
    end
  end

  def mergeTemplate templateFile

    log :info, "merge " + templateFile

    if @options[:merge]
      content = IO.read templateFile

      mergedContent = doRender content
      IO.write templateFile, mergedContent
    end
  end

  def doRender content

    controller = MergeController.new
    controller.name = @options[:name]
    controller.index

    renderer = ERB.new content

    renderer.result controller.getBinding
  end

  def textfile? file

    matched = File.file? file

    if matched
      matched = matched || File.fnmatch?(file, '*.rb')
      matched = matched || File.fnmatch?(file, '*.md')
      matched = matched || File.fnmatch?(file, 'README*')
      matched = matched || File.fnmatch?(file, 'LICENSE')
      matched = matched || File.fnmatch?(file, '*.txt')
      matched = matched || File.fnmatch?(file, 'Gemfile')
      matched = matched || File.fnmatch?(file, 'Rakefile')
      matched = matched || File.fnmatch?(file, '*.gemspec')
      matched = matched || File.fnmatch?(file, '*.yaml')
      matched = matched || File.fnmatch?(file, '*.yml')
    end

    matched
  end

  def log type, message

    puts message.to_s if @options[:verbose] && type == :info
    puts "Warn: " + message.to_s if type == :warn

  end

end

Main.new(ARGV).run
