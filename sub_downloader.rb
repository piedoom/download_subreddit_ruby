require 'rest-client'
require "open-uri"
require 'nokogiri'
require 'optparse'
require 'fileutils'
require 'colorize'

class Readit
	# accessing stuff
	attr_accessor :all_links, :filename
	
	# add imgur image links from a nokogiri HTML document object
	def extract_imgur html
		r = [Array.new]
		html.css('a').each do |a|
			unless a['href'].nil?
				r << a['href'] if a['href'].match /^http(s)?\:\/\/(i\.)?imgur.com/
			end
		end
		return r.flatten
	end
	
	# get the link to the next page from a nokogiri HTML document object
	def extract_next_link html
		html.css('.nextprev>a').each do |a|
			return a['href'] if a['rel'].include? "next"
		end
		# false if no links are found (end of results)
		return false
	end
	
	# fetch a web page and return a nokogiri HTML document object
	def fetch_web_page url
		Nokogiri::HTML(RestClient.get(@base + url))
	end
	
	# fetch a web page without a root and return a nokogiri HTML document object
	def fetch_regular_url url
		Nokogiri::HTML(RestClient.get(url))
	end
	
	# remove reddit link
	def sanitize_url url
		url.slice((url.index('/r/') + 3) .. -1)
	end
	
	# download imgur links
	def download images
		images.each do |image|
			parse_and_download_img image
		end
	end
	
	# parse all image tags and get src attributes. takes an array of strings
	def parse_and_download_img html
		html = fetch_regular_url(html)
		# if a regular page
		
		# if an album
		html.css("img").each do |img|
			if img['src']
				if img['src'].include? 'i.imgur.com'
					#File.open("#{Dir.pwd}/#{@filename}/#{@filename}", 'wb') do |f|
					#	f.write open(img[:src]).read 
					#end
				end
			end
		end
		
	end
		
	# fetch all imgur links in a page
	def fetch_imgur_links url
		html = Nokogiri::HTML(RestClient.get(@base + url))
		# return list of new imgur links
		image_list = extract_imgur(html)
		# download the images if the option is enabled
		download image_list if @options[:download]
		# append to a giant file
		@all_links << image_list
		url = extract_next_link html
		if url
			return sanitize_url url
		else
			return false
		end
	end
	
	# init
	def initialize options
		@options = options
		
		# setting the filename
		if @options[:name]
			@filename = @options[:name]
		else
			@filename = @options[:reddit] + "_" + Time.now.strftime("results_%m-%e-%y_%s")
		end		
		
		Dir.mkdir filename
		
		@base = 'http://www.reddit.com/r/'
		@options[:pages] ? pages = @options[:pages].to_i : pages = 100
		@all_links = Array.new
		counter = 0
		# get subreddit name to append to @base
		subreddit = @options[:reddit] + '/new/'
		
		# begin fetching imgur stuff
		page = fetch_imgur_links subreddit
		# if next page
		while page and counter < pages
			page = fetch_imgur_links page
			print "#{pages - counter} pages left.\r".yellow
			counter += 1
		end
		puts "\nFinished compiling imgur links.  Saved in folder #{filename}".green
		# make into a string
		@all_links = @all_links.join("\n")
		File.open("#{filename}/#{filename}.txt", 'w') { |file| file.write(@all_links) }
	end
end

# create command line options
options = Hash.new
OptionParser.new do |opts|
	opts.on("-r", "--reddit=val", "Specify reddit to download from") do |r|
		options[:reddit] = r
	end
	opts.on("-p", "--pages=val", "Specify how many pages - default is 100") do |r|
		options[:pages] = r
	end
	opts.on("-d", "--download", "Download images") do |r|
		options[:download] = r
	end
	opts.on("-n", "--name=val", "Name for files") do |r|
		options[:name] = r
	end
end.parse!

readit = Readit.new(options)