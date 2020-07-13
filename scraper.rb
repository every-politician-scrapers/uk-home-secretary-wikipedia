#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require_relative 'lib/unspan_all_tables'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links
  decorator UnspanAllTables

  field :officeholders do
    list.xpath('.//tr[td]').map { |td| fragment(td => HolderItem) }.reject(&:empty?).map(&:to_h).uniq(&:to_s)
  end

  private

  def list
    noko.xpath('//h2[contains(.,"List of Home Secretaries")]//following::table[1]')
  end
end

class HolderItem < Scraped::HTML
  field :id do
    tds[2].css('a/@wikidata').map(&:text).first
  end

  field :name do
    tds[2].css('a/@title').map(&:text).map(&:tidy).first
  end

  field :start_date do
    Date.parse(start_text) rescue nil
  end

  field :end_date do
    return if end_text == 'Incumbent'
    Date.parse(end_text) rescue nil
  end

  field :replaces do
  end

  field :replaced_by do
  end

  def empty?
    name.to_s == ''
  end

  private

  def tds
    noko.css('td,th')
  end

  def start_text
    tds[3].text.tidy
  end

  def end_text
    tds[4].text.tidy
  end
end

url = URI.encode 'https://en.wikipedia.org/wiki/Home_Secretary'
data = Scraped::Scraper.new(url => MembersPage).scraper.officeholders

data.each_cons(2) do |prev, cur|
  cur[:replaces] = prev[:id]
  prev[:replaced_by] = cur[:id]
end

header = data[1].keys.to_csv
rows = data.map { |row| row.values.to_csv }
puts header + rows.join
