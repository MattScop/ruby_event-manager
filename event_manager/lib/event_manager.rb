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
# INCLUDE FORM LETTER & SAVE IT
    require 'csv'
    require 'google/apis/civicinfo_v2'
    require 'erb'

    def clean_zip_codes(zip_code)
        # if the zip code is missing, then add 00000
        # if the zip code is more than five digits, truncate it to the first five digits
        # if the zip code is less than five digits, add zeros to the front until it becomes five digits
        # if the zip code is exactly five digits, assume that it is ok
        zip_code.to_s.rjust(5, '0')[0..4]
    end

    def clean_phone_numbers(phone_number)
        # If the phone number is less than 10 digits, assume that it is a bad number
        # If the phone number is 10 digits, assume that it is good
        # If the phone number is 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
        # If the phone number is 11 digits and the first number is not 1, then it is a bad number
        # If the phone number is more than 11 digits, assume that it is a bad number
        phone_number_split = phone_number.split('')
        phone_number_digits = phone_number_split.select { |item| item.match(/\d/) }
        phone_number_length = phone_number_digits.length
        case true
        when !phone_number_length.between?(10, 11) then 'Phone number is not correct'
        when phone_number_length == 11
            if phone_number_digits[0] == '1'
                index = phone_number_split.index('1')
                phone_number_split.delete_at(index)
                phone_number_split.join
            else
                'Phone number is not correct'
            end
        else
            phone_number
        end
    end
    
    def legislators_by_zip_code(zip_code)
        civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
        civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

        begin
            legislators = civic_info.representative_info_by_address(
                address: zip_code,
                levels: 'country',
                roles: ['legislatorUpperBody', 'legislatorLowerBody']
            ).officials
        rescue
            'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
        end
    end

    def save_thank_you_letter(id,form_letter)
        Dir.mkdir 'output' unless Dir.exist?('output')
        filename = "output/thanks_#{id}.html"
        File.open(filename, 'w') do |file|
            file.puts form_letter
        end
    end
    
    template_letter = File.read('../form_letter.erb')
    erb_template = ERB.new template_letter
    
    contents = CSV.open('../event_attendees.csv', headers: true, header_converters: :symbol)
    registration_hours = [] #collect registration hours
    contents.each do |line|
        id = line[0]
        name = line[:first_name]
        zip_code = clean_zip_codes(line[:zipcode])
        phone_number = clean_phone_numbers(line[:homephone])
        legislators = legislators_by_zip_code(zip_code)
        registration_hours << Time.strptime(line[:regdate], "%m/%d/%Y %k:%M").hour

        ###########################################
        # form_letter = erb_template.result(binding)
        # save_thank_you_letter(id, form_letter)
    end

    peak_hours = registration_hours.reduce({}) do |obj, current|
        obj["Registered at #{current}"] = 1 unless obj["Registered at #{current}"]
        obj["Registered at #{current}"] += 1
        obj
    end
    
    pp peak_hours.sort_by{ |_key, value| value }.reverse.to_h
    