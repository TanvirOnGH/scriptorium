#!/usr/bin/env ruby

require 'find'
require 'ruby-progressbar'
require 'optparse'

def human_size(size)
  units = %w[B KB MB GB TB]
  i = 0
  while size >= 1024 && i < 4
    size /= 1024.0
    i += 1
  end
  "%.2f %s" % [size, units[i]]
end

def analyze_directory(directory, max_depth = Float::INFINITY, show_file_summary = false)
  total_size = 0
  total_files = 0
  total_folders = 0
  largest_file = ''
  largest_file_size = 0
  largest_folder = ''
  largest_folder_size = 0
  file_types = Hash.new(0)

  total_entries = Dir.glob("#{directory}/**/*", File::FNM_DOTMATCH).length
  progressbar = ProgressBar.create(title: "Analyzing", total: total_entries, format: '%a %e %P% Processed: %c from %C')

  Find.find(directory) do |path|
    current_depth = path.split('/').count - directory.split('/').count
    next if current_depth > max_depth

    if File.file?(path)
      total_files += 1
      file_size = File.size(path)
      total_size += file_size

      if file_size > largest_file_size
        largest_file = path
        largest_file_size = file_size
      end

      if show_file_summary
        file_ext = File.extname(path)
        file_types[file_ext[1..-1].downcase] += File.size(path) unless file_ext.empty? 
      end

    elsif File.directory?(path) && path != directory
      total_folders += 1

      folder_size = Dir.glob("#{path}/**/{*,.*}").
                      select { |f| File.file?(f) }.
                      sum { |f| File.size(f) }

      if folder_size > largest_folder_size
        largest_folder = path
        largest_folder_size = folder_size
      end
    end

    progressbar.increment
  end
  progressbar.finish

  return total_size, total_files, total_folders, largest_file, 
        largest_file_size, largest_folder, largest_folder_size, file_types
end

if ARGV.empty?
  puts "Usage: #{$0} <directory> [options]"
  puts "Options:"
  puts "  -d, --depth LEVELS     Maximum recursion depth (default: unlimited)"
  puts "  -s, --summary        Show file type summary"
  exit 1
end

directory = File.expand_path(ARGV[0])
max_depth = Float::INFINITY
show_file_summary = false

options = {}
OptionParser.new do |opts|
  opts.on("-d", "--depth LEVELS", Integer, "Maximum recursion depth") do |depth|
    options[:depth] = depth
  end
  opts.on("-s", "--summary", "Show file type summary") do 
    options[:summary] = true
  end
end.parse!

max_depth = options[:depth] || Float::INFINITY
show_file_summary = options[:summary] || false

unless File.directory?(directory)
  puts "Error: '#{directory}' is not a valid directory."
  exit 1
end

total_size, total_files, total_folders, largest_file, largest_file_size, 
  largest_folder, largest_folder_size, file_types = analyze_directory(directory, max_depth, show_file_summary)

puts ""
puts "Directory Analysis for: #{directory}"
puts "---------------------------------"
puts "Total Size:       #{human_size(total_size)}"
puts "Total Files:      #{total_files}"
puts "Total Folders:    #{total_folders}"
puts "Largest File:     #{largest_file} (#{human_size(largest_file_size)})"
puts "Largest Folder:   #{largest_folder} (#{human_size(largest_folder_size)})"

if show_file_summary 
  puts "\nFile Type Summary:"
  file_types.each do |ext, size|
    puts "- #{ext.empty? ? "(No extension)" : ext}: #{human_size(size)}"
  end
end