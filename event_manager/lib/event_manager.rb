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
    content = File.readlines('event_attendees.csv')
    content.each_with_index do |line, idx|
        next if idx == 0 # skip the header
        names = line.split(',')[2]
        puts names
    end
