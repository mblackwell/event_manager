# Dependencies
require "csv"
require 'sunlight'

# Class Definition
class EventManager
  
  Sunlight::Base.api_key = "e179a6973728c4dd3fb1204283aaccb5"
  
  def initialize(filename)
    puts "EventManager Initialized."
    @file = CSV.open(filename, {headers: true, header_converters: :symbol})
  end
  
  def print_names
      @file.each do |line|
        puts line[:first_name] + " " + line[:last_name]
      end
  end 
  
  def print_numbers
    @file.each do |line|
          number = clean_number(line[:homephone])
          if number != "0000000000"
          puts number
          end
    end
  end
    def clean_number(original)
       @file.each do |line|
         number = line[:homephone]
           if number.length == 10
             # Do Nothing
           elsif number.length == 11
             if number.start_with?("1")
               number = number[1..-1]
             else
               number = "0000000000"
             end
           else
             number = "0000000000"
           end
        return number  # Send the variable 'number' back to the method that called this method
    end 

end 

    def print_zipcodes
      @file.each do |line|
        zipcode = clean_zipcode(line[:zipcode])
        puts zipcode
      end
    end
    
    def clean_zipcode(zip)
        if zip.nil?
              result = "00000"  
          elsif zip.length < 5
            zip.to_s.rjust(5, '0')  
        else
        return zip 
        end
    end
    
    def output_data(filename)
      output = CSV.open(filename, "w")
      @file.each do |line| 
        if @file.lineno == 2
        output << line.headers
        end
        line[:homephone] = clean_number(line[:homephone])
        line[:zipcode] = clean_zipcode(line[:zipcode])
        output << line 
      end
    end
    
    def rep_lookup
        20.times do
          line = @file.readline
          representative = "unknown"
          legislators = Sunlight::Legislator.all_in_zipcode(clean_zipcode(line[:zipcode]))
          names = legislators.collect do |leg|
            first_name = leg.firstname
            first_initial = first_name[0]
            last_name = leg.lastname
            first_initial + ". " + last_name
          end
          puts "#{line[:last_name]}, #{line[:first_name]}, #{line[:zipcode]}, #{names.join(", ")}"
        end
      end
    
    
      def create_form_letters
          letter = File.open("form_letter.html", "r").read
          20.times do
            line = @file.readline

            custom_letter = letter.gsub("#first_name", line[:first_name].to_s)
            custom_letter = custom_letter.gsub("#last_name", line[:last_name].to_s)
            
            filename = "output/thanks_#{line[:last_name]}_#{line[:first_name]}.html"
            output = File.new(filename, "w")
            output.write(custom_letter)
          end
        end
    
        def rank_times
            hours = Array.new(24){0}
            @file.each do |line|
             timestamp = line[:regdate].split(" ")
             time = timestamp[1]
             hr = time.split(":")
             hour = hr[0]
             
             hours[hour.to_i] = hours[hour.to_i] + 1
            end
            hours.each_with_index{|counter,hour| puts "#{hour}\t#{counter}"}
        end
    
        
        def day_stats
            days = Array.new(7){0}
            @file.each do |line|
              datestamp = line[:regdate].split(" ")
              date = datestamp[0]
              date = Date.strptime(date, "%m/%d/%y")
              day = date.wday
              
              
              days[day.to_i] = days[day.to_i] + 1
            end
            days.each_with_index{|counter,day| puts "#{day}\t#{counter}"}  
        end
        
        
        def state_stats
            state_data = {}
            @file.each do |line|
              state = line[:state]  # Find the State
                    if state_data[state].nil? # Does the state's bucket exist in state_data?
                      state_data[state] = 1 # If that bucket was nil then start it with this one person
                    else
                      state_data[state] = state_data[state] + 1  # If the bucket exists, add one
                    end
                    
            end
            state_data = state_data.select{|state, counter| state}.sort_by{|state, counter| state unless state.nil?}
            state_data.each do |state, counter|
              puts "#{state}: #{counter}"
            end
          
        end
        
        
        
        
        
        
    
end

    


# Script
manager = EventManager.new("event_attendees.csv")
manager.state_stats


