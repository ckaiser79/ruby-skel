#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'find'

class Main
  def initialize argv

    @options = {}

    argv << "-h" if argv.empty?

    p = OptionParser.new do |opts|
      opts.banner = "Usage: set-name.rb [options]"

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
      end

      @options[:name] = 'default'
      opts.on("-n", "--name NAME", "name of project") do |v|
        options[:name] = v
      end

      @options[:targetdir] = 'target'
      opts.on("-t", "--target DIR", "Directory where files should be copied to") do |v|
        options[:targetdir] = v
      end

      @options[:skeldir] = '../skel'
      opts.on("-s", "--skel DIR", "Directory where files are located") do |v|
        options[:skeldir] = v
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

    FileUtils.cp_r @options[:skeldir] + '/.', @options[:targetdir]

    files = findFilesNeedsRenaming
    files.each do |file|
      renameFile file
    end

    findAndMergeTemplates

  end

  private

  def renameFile file

    match = /(.*)(#{@options[:name]})(.*)/.match file

    if match.nil?
      newFileName = file
    else
      newFileName = match[1] + @options[:name] + match[3]
    end

    newFileName
  end

  def findFilesNeedsRenaming
    files = []

    Find.find @options[:targetdir] do |file|
      files.push file if file.contains? @options[:name]
    end

    files.reverse
  end

  def findAndMergeTemplates
    Find.find @options[:targetdir] do |file|
      mergeTemplate file
    end
  end

  def mergeTemplate templateFile
    if textfile? templateFile


      content = IO.read templateFile
      renderer = ERB.new content

      mergedContent = doRender renderer, content
      IO.write templateFile, mergedContent


    end
  end

  def doRender renderer, content

    # variables for erb template
    name = @options[:name]
    nameOfModule = toCamelCase @options[:name]

    renderer.result
  end

  def textfile? file
    matched = file.file?

    matched = matched && file.name.fnmatch?('*.rb')
    matched = matched && file.name.fnmatch?('*.md')
    matched = matched && file.name.fnmatch?('README*')
    matched = matched && file.name.fnmatch?('LICENSE')
    matched = matched && file.name.fnmatch?('*.txt')
    matched = matched && file.name.fnmatch?('Gemfile')
    matched = matched && file.name.fnmatch?('Rakefile')
    matched = matched && file.name.fnmatch?('*.gemspec')
    matched = matched && file.name.fnmatch?('*.yaml')
    matched = matched && file.name.fnmatch?('*.yml')

    matched
  end

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

end

Main.new(ARGV).run
