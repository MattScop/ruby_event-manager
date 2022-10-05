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
# INCLUDE GOOGLE CIVIC API
    require 'csv'
    require 'google/apis/civicinfo_v2'

    def clean_zip_codes(zip_code)
        # if the zip code is missing, then add 00000
        # if the zip code is more than five digits, truncate it to the first five digits
        # if the zip code is less than five digits, add zeros to the front until it becomes five digits
        # if the zip code is exactly five digits, assume that it is ok
        zip_code.to_s.rjust(5, '0')[0..4]
    end
    
    def legislators_by_zip_code(zip_code)
        civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
        civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

        begin
            legislators = civic_info.representative_info_by_address(
                address: zip_code,
                levels: 'country',
                roles: ['legislatorUpperBody', 'legislatorLowerBody']
            )
            legislators = legislators.officials
            legislators_names = legislators.map(&:name)
            legislators_names.join(', ')
        rescue
            'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
        end
    end
    
    contents = CSV.open('../event_attendees.csv', headers: true, header_converters: :symbol)
    contents.each do |line|
        name = line[:first_name]
        zip_code = clean_zip_codes(line[:zipcode])
        legislators = legislators_by_zip_code(zip_code)
        puts "#{name} #{zip_code} #{legislators}"
    end

