
require 'rubygems'
require 'bundler/setup'

class Main
	def initialize argv


		@options = {}

		p = OptionParser.new do |opts|

			

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

