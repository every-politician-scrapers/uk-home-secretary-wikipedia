#!/bin/env ruby
# frozen_string_literal: true

# Check a Wikipedia scraper outfile against what's currently in
# Wikidata, creating wikibase-cli commands for any additions to make.

require 'csv'
require 'pry'

# TODO: sanity check the input
wikipedia_file = Pathname.new(ARGV.first) # output of scraper
wikidata_file = Pathname.new(ARGV.last) # `wd sparql term-members.sparql`

class InputFile
  def initialize(pathname)
    @pathname = pathname
  end

  REMAP = {
    'item' => 'id',

    'party' => 'P4100',
    'group' => 'P4100',

    'area' => 'P768',
    'constituency' => 'P768',

    'start' => 'P580',
    'starttime' => 'P580',
    'startdate' => 'P580',
    'start_time' => 'P580',
    'start_date' => 'P580',

    'end' => 'P582',
    'endtime' => 'P582',
    'enddate' => 'P582',
    'end_time' => 'P582',
    'end_date' => 'P582',

    'replaces' => 'P1365',

    'replaced_by' => 'P1366',
    'replacedby' => 'P1366',

    'cause' => 'P1534',
    'end_cause' => 'P1534',
    'endcause' => 'P1534',
  }

  def data
    # TODO: warn about unexpected keys in either file
    @data ||= raw.map do |row|
      row.transform_keys { |k| REMAP.fetch(k.to_s, k).to_sym }
        .transform_values do |v|
          v = v[:value] if v.class == Hash
          v.to_s.sub('T00:00:00Z','')
        end
    end
  end

  def find(id)
    data.select { |row| row[:id] == id }
  end

  attr_reader :pathname

  class CSV < InputFile
    require 'csv'

    def raw
      @data ||= ::CSV.table(pathname).map(&:to_h)
    end
  end

  class JSON < InputFile
    require 'json'

    def raw
      @data ||= ::JSON.parse(pathname.read, symbolize_names: true)
    end
  end
end

wikipedia = InputFile::CSV.new(wikipedia_file)
wikidata = InputFile::JSON.new(wikidata_file)

wptally = wikipedia.data.map { |r| r[:id] }.tally
wdtally = wikidata.data.map { |r| r[:id] }.tally
no_P39s = wptally.keys - wdtally.keys

wikipedia.data.each do |to_add|
  # TODO: warn which ones we're skipping (but only once each)
  next unless (wptally[to_add[:id]] == 1) && (wdtally[to_add[:id]] == 1)

  existing = wikidata.find(to_add[:id])

  to_add.keys.select { |key| key[/^P\d+/] }.each do |property|
    wp_value = to_add[property]
    next if wp_value.to_s.empty?

    wd_value = existing.first[property] rescue binding.pry

    if wp_value.to_s == wd_value.to_s
      # warn "#{existing.first} matches on #{property}"
      next
    end

    if (!wd_value.to_s.empty? && (wp_value != wd_value))
      warn "*** MISMATCH for #{to_add[:id]} #{property} ***: WP = #{wp_value} / WD = #{wd_value}"
      next
    end

    puts [existing.first[:statement], property.to_s, wp_value].join " "
  end
end

warn "## No suitable P39s for:\n\t#{no_P39s.join ' '}" if no_P39s.any?

