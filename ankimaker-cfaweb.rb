#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pp'

# Anki (http://ankisrs.net/) is a flashcard program. This script
# extracts pictures and descriptions from an HTML file and exports
# it in a Anki-friendly format to make it easy to learn who people
# are.
#
# As currently written, it just works on the CfA web site team page.
# This is left more as an example; the ankimaker-cfa script is the
# useful version.

source = 'http://www.codeforamerica.org/about/team/'
doc = Nokogiri::HTML(open(source))


#puts doc.css(".views-field")
doc.css(".h-card").each do |lump|
  pic = '<img src="' + URI.join(source,lump.css('.profile-photo').first.attr('src')).to_s + '"/>'
  text = lump.css('.p-name').first.children.to_s.gsub("\n",'')
  bio = lump.css('.p-note p').map {|x| x.content.to_s.gsub("\n",'')}.join('<br/>')
  group = "foo"

  target = lump
  while target.name != 'section'
    target = target.parent
  end
  group = target.css("h4").first.text
  tags = group.downcase.gsub(/\s+/,'')


#puts "#{pic}\t#{group}<br>#{text}<hr>#{bio}\t#{tags}"
puts "#{pic}\t#{group}<br>#{text}<hr>#{bio}\t#{tags}"
end

