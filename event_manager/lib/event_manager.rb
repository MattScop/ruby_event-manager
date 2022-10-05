puts 'Event Manager Initialized!'

# HOW TO QUICKLY GET INFORMATION FROM A FILE
    # contents = File.read('event_attendees.csv')
    # puts contents if File.exist? 'event_attendees.csv'
    # //
    # content = File.readlines('event_attendees.csv')
    # content.each do |line|
    #     puts line
    # end
# GET INFO ONLY FROM A SPECIFIC COLUMN
    # content = File.readlines('event_attendees.csv')
    # content.each_with_index do |line, idx|
    #     next if idx == 0 # skip the header
    #     names = line.split(',')[2]
    #     puts names
    # end
# SWITCHING TO CSV LIBRARY
    require 'csv'

    def clean_zip_codes(zip_code)
        # if the zip code is missing, then add 00000
        # if the zip code is more than five digits, truncate it to the first five digits
        # if the zip code is less than five digits, add zeros to the front until it becomes five digits
        # if the zip code is exactly five digits, assume that it is ok
        zip_code.to_s.rjust(5, '0')[0..4]
    end
    
    contents = CSV.open('../event_attendees.csv', headers: true, header_converters: :symbol)
    contents.each do |line|
        name = line[:first_name]
        zip_code = clean_zip_codes(line[:zipcode])
        puts "#{name} #{zip_code}"
    end
    