require_relative 'price'

class WriteData
  def write_file
    codes = IO.readlines('code.txt')
    codes.each{ |code|
      puts code
      data = Price::PriceParser.new.price(code)
      File.open("data/#{code}".chomp,'a') do |file|
        file.puts data.tocsv
      end
    }
  end
end

WriteData.new.write_file
