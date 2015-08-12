#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'optparse'

$url_file = "example-tracks.txt"
$csv_file = false

csv_options = { :force_quotes => true, :col_sep => ';' }

OptionParser.new do |opts|
  opts.banner  = "Usage: spotify-track-list.rb [options]"
  opts.banner += "\nExample: spotify-track-list.rb -i urls.txt -o tracks.csv"
  opts.on( "-iURLFILE", "--input=urlfile.txt", "Text file with url list" ) { |inputfile| $url_file = inputfile }
  opts.on( "-oTRACKLIST", "--output=tracklist.csv", "Output csv file for track info" ) { |outputfile| $csv_file = outputfile }
end.parse!

unless File.exists? $url_file 
  $stderr.puts "Error: input url file (#{$url_file}) does not exist"
  exit 1
end

header = [ "Artist", "Album", "Track" ]
if $csv_file
  csv = CSV.open( $csv_file, 'wb', csv_options ) 
  csv << header
else
  puts CSV.generate_line header, csv_options
end

File.new( $url_file ).each_line do |url|
  doc = Nokogiri::HTML(open(url.strip))

  title = doc.at_css( 'div.h-data h1.h-title' ).text()
  album = doc.at_css( 'div.h-data span.show-mobile.h-label' ).text()
  artist = doc.at_css( 'div.h-data a.button.owner-action' ).text()

  if $csv_file
    puts "Artist: #{artist}"
    puts "Title : #{title}"
    puts "Album : #{album}"
    puts "---------"

    csv << [ artist, album, title ]
  else
    puts CSV.generate_line [ artist, album, title ], csv_options
  end
end
