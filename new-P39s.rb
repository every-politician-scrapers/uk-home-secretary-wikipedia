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

wikipedia.data.each do |wp|
  next unless wptally[wp[:id]] > wdtally[wp[:id]]
  existing = wikidata.find(wp[:id])

  # Skip this entry if anything in WD has the same start/end date
  # TODO: check for anything in an overlapping range
  next if existing.any? { |wd| (wp[:P580] == wd[:P580]) || (wp[:P582] == wd[:P582]) }

  warn "\n#{wp[:name]}: WP: #{wptally[wp[:id]]} // WD: #{wdtally[wp[:id]]}"
  existing.each do |wd|
    warn "    WD has #{wd[:P580]} – #{wd[:P582]}"
  end

  warn "    To add #{wp[:P580]} - #{wp[:P582]} call:"
  puts ['add_full_P39.js', wp.values_at(:id, :P580, :P582, :P1365, :P1366)].join(' ')
end
