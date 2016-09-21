#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def idify(a)
  name = a.xpath('./@class').text == 'new' ? a.text : a.attr('title').value
  name.tr(' ', '-').downcase
end

def scrape(url)
  noko = noko_for(url)

  constituency = ''
  noko.xpath('.//h2[contains(.,"Current members")]/following-sibling::table[1]//tr[td]').each do |tr|
    tds = tr.css('td')
    constituency = tds.shift if tds.count == 3

    next if tds[0].text.strip == 'Vacant'
    data = {
      id: idify(tds[0].css('a')),
      name: tds[0].text.strip,
      wikipedia__en: tds[0].xpath('a[not(@class="new")]/@title').text.strip,
      area: constituency.text,
      party: tds[1].text,
      term: '2011',
      source: url
    }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

scrape('https://en.wikipedia.org/wiki/House_of_Keys')
