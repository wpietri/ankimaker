#!/usr/bin/ruby
# encoding: UTF-8

require 'nokogiri'
require 'open-uri'
require 'pp'

# Anki (http://ankisrs.net/) is a flashcard program. This script
# extracts pictures and descriptions from the codeforamerica.org
# source tree and assembles it into an Anki-friendly format to
# make it easy to learn who people are.
#
# Note that tags are useful to sort cards into groups. Here they
# are tagged by department/role/fellowship year. A plausible way
# for a new employee to use this is to import everything and then
# suspend all the cards that are not immediately relevant.


def tags_for(strings) 
  strings.
      map{|i| i.downcase.gsub(/\s+/,'_')}.
      reject{|i| i =~/brigade$|team$|^code_for|^openoakland$/}.
      map{|i| i.gsub(/fellow$/,'fellows')}
      
end

def teams_for(path) 
  teams = Hash.new
  File.open(path, "r:utf-8") do |f|
    doc = Nokogiri::HTML(f,nil,'UTF-8')
    doc.css('section').each do |section|
      h4=section.css("h4").first
      next unless h4
      team=section.css("h4").first.text
      next unless team
      section.css('ul li').each do |item|
      filename = /.*people.([^.]+[.]html).*/.match(item.text)[1]
      teams[filename] = team
      end
        
    end
  end
  teams
end

path = ARGV[0]

count = Hash.new(0)

teams = teams_for(File.join(path,"about/team/index.html"))

people_dir = File.join(path,"_includes/people")
Dir.foreach(people_dir) do |filename|
  next unless filename =~ /^[a-z]/
  person_file = File.join(people_dir,filename)
  File.open(person_file, "r:utf-8") do |f|
    doc = Nokogiri::HTML(f,nil,'UTF-8')
    doc.encoding = 'utf-8'
    name = doc.css('.p-name').first.text.strip
    photo = doc.css('.profile-photo').first.attr('src').gsub(/\s*{{\s*include.base\s*}}\s*/,'https://www.codeforamerica.org\1');
    next if photo =~ /generic-/
    bio = doc.css('p.p-note').map {|x| x.content.to_s.gsub("\n",'')}.join('<br/>').gsub(/\s+/, ' ')
    title = doc.css("div.layout-minor p").map{|i| i.text}.first
    memberof = doc.css("div.layout-minor ul li").map{|i| i.text}
    tags = tags_for(memberof)
    if tags.include?('staff') && !teams[filename]
      $stderr.puts "Missing from staff page: #{filename}"
    end
    if teams[filename] && !tags.include?('staff')
      $stderr.puts "Missing staff tag: #{filename}"
      tags << 'staff'
    end
    front = "<img height='300px' src= #{photo} />"
    back = "<b>#{name}</b><br/>"
    back << "<b>#{title}</b><br/>" if title
    back << "#{teams[filename]}<br>" if teams[filename]
    back << "#{memberof.join(', ')}<br>" if memberof
    back << "<hr>#{bio}"
    puts "#{front}\t#{back}\t#{tags.join(' ')}"
    
  end
end

exit 0
