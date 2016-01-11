require 'net/http'
require 'rubygems'
require 'nokogiri'

module Price
  class PriceData
    attr_reader :date, :yclose, :open, :close, :high, :low, :volume
    def initialize(date,yclose,open,close,high,low,volume)
      @date=date
      @yclose=yclose
  	  @open=open
  	  @close=close
  	  @high=high
  	  @low=low
  	  @volume=volume
    end
    def printout
      puts "date:#{@date} yestoday:#{@yclose} open:#{@open} close:#{@close} high:#{@high} low:#{@low} volume:#{@volume}"
    end
    def tocsv
      "#{@date},#{@yclose},#{@open},#{@close},#{@high},#{@low},#{@volume}"
    end
  end

  class PriceParser
    def request(code)
      uri = URI('http://stocks.finance.yahoo.co.jp/stocks/detail/')
      params = {:code => code}
      uri.query = URI.encode_www_form(params)
      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        return res.body
      else
        return "error with http request"
      end
    end
    def parse(body)
      page = Nokogiri::HTML(body)
      links = page.css("dd[class='ymuiEditLink mar0']")
      close_link = page.css("td[class='stoksPrice']")
      date = get_date(links[1].text)
      yclose = get_value(links[0].text)
      open = get_value(links[1].text)
      close = get_value(close_link[0].text)
      high = get_value(links[2].text)
      low = get_value(links[3].text)
      volume = get_value(links[4].text)
      PriceData.new(date,yclose,open,close,high,low,volume)
    end
    def get_date(text)
      "#{Time.new.year}/" + text.split("（").at(1).delete('）').chop
    end
    def get_value(text)
      text.split("（").at(0).delete(',株').tr("\n","")
    end
    def price(code)
      return parse(request(code))
    end
  end
end
puts Price::PriceParser.new.price(1301).high
