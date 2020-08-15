# Description
# Parse MD files from awesome- list
# the output is saved as a CSV file

require 'csv'

if ARGV.length != 2
    puts "Usage: ruby parse-awesome.rb <input-file.md> <output-file.csv>"
    exit
end

# Arguments
input_file_name = ARGV[0]
output_file_name = ARGV[1]

# Configurable parameters
# Categories to remove
filtered_categories = ["Twitter", "Communities", "Websites", "Podcasts and Screencasts"]


# ----------------
# Script variables
category_name_regexp = /###\s\w+/
category_desc_regexp = /_[\w\s\d\.]+_/
lst_entry_regexp = /-[\s\w\d\[\]\(\)\/:\.\-\!_]+./

category_name = ""
category_desc = ""
lst_entry = ""
csv_lines = [["category.name", "category.desc", "project.name", "project.link", "project.desc"]]

File.foreach(input_file_name) do |line| 

    if line.match(category_name_regexp)
        category_name = line
        category_name.gsub!(/[^0-9A-Za-z\s]/, '').strip!
        next
    end

    if line.match(category_desc_regexp)
        category_desc = line
        category_desc.gsub!(/[^0-9A-Za-z\.\s]/, '').strip!
        next
    end

    if line.match(lst_entry_regexp) and !category_name.empty? and !category_desc.empty?
        lst_entry = line.split(%r{[\[\]\(\)]|( - )})
        name = lst_entry[1]
        link = lst_entry[3]
        desc = lst_entry[6]
        next if name.nil? or link.nil? or desc.nil? or name.empty? or link.empty?
        next if filtered_categories.include? category_name
        csv_line = [category_name, category_desc, name.strip, link.strip, desc.strip]
        csv_lines << csv_line     
    end

end

CSV.open(output_file_name, "wb") do |csv| 
    csv_lines.each do |line| 
        csv << line
    end
end