#!/bin/env ruby
# frozen_string_literal: true

# Check a Wikipedia scraper outfile against what's currently in
# Wikidata, suggesting new P39s to add

require 'csv'
require 'pry'

require_relative 'lib/inputfile'

# TODO: sanity check the input
wikipedia_file = Pathname.new(ARGV.first) # output of scraper
wikidata_file = Pathname.new(ARGV.last) # `wd sparql term-members.sparql`

wikipedia = InputFile::CSV.new(wikipedia_file)
wikidata = InputFile::JSON.new(wikidata_file)

wptally = wikipedia.data.map { |r| r[:id] }.tally
wdtally = wikidata.data.map { |r| r[:id] }.tally

wikipedia.data.each do |to_add|
  next unless wptally[to_add[:id]] > wdtally[to_add[:id]]

  warn "\n#{to_add[:name]}: WP: #{wptally[to_add[:id]]} // WD: #{wdtally[to_add[:id]]}"
  # TODO check if any of the existing have the same dates
  wikidata.find(to_add[:id]).each do |existing|
    warn "    WD has #{existing[:P580]} – #{existing[:P582]}"
  end

  warn "    To add #{to_add[:P580]} - #{to_add[:P582]} call:"
  puts ['wd ee add_full_P39.js', to_add.values_at(:id, :P580, :P582, :P1365, :P1366)].join(' ')
end
