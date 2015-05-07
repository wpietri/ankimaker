#!/usr/bin/ruby

require 'nokogiri'
require 'pp'

# Anki (http://ankisrs.net/) is a flashcard program. This script
# extracts pictures and descriptions from an HTML file and exports
# it in a Anki-friendly format to make it easy to learn who people
# are.
#
# As currently written, it just works on the Kiva team page.
# Making it more magic is probably not worth it; better just to
# custom-write the expressions each time.
#
# Note that tags are useful to sort cards into groups. Here they
# are tagged by department.

doc = Nokogiri::HTML(File.open("kiva-team.html"))


#puts doc.css(".views-field")
doc.css(".views-field").each do |lump|
pic = lump.css('img').first.to_s
text = lump.css('.photo-title').first.children.to_s.gsub("\n",'')
bio = lump.css('.taL').first.content.to_s.gsub("\n",'')

target = lump
while target.name != 'table'
  target = target.parent
end
group = target.previous_sibling.previous_sibling.content
tags = group.downcase.gsub(/\s+/,'')


puts "#{pic}\t#{group}<br>#{text}<hr>#{bio}\t#{tags}"
end

