#!/usr/bin/env ruby
require 'digest/md5'

# Features to add:
# arguments used as a list of directories
# -X num_of_threads multi-threaded checksumming
# -R descend into directories to find dupes
# -r max_depth
# -l -g or --local --global  option to check for dupes between all directories or only within a directory
# -c algo other hashing algos
# -flist option to dump delimited lists of matching files
# -n don't print newest copies
# -o don't print oldest copies

#unless ARGV.size > 0
#  print "Operate on current directory <#{Dir.pwd}>? (Y/n) "
#  unless gets.chomp == 'Y'
#    abort
#  end
#  ARGV << Dir.pwd
#end

files = {}

# Build a hashmap of hashes and filenames of files with matching hashes
Dir['*'].each do |filename|
  chksm = Digest::MD5.hexdigest(File.read(filename))
  unless files[chksm]
    files[chksm] = []
  end
  files[chksm] << filename
end

dupe_filenames = files.select do |k,v|
  v.size > 1
end.map do |k,v|
  v.sort_by do |filename|
    File.ctime(filename).to_i
  end[1..-1]
end.flatten

dupe_filenames.each do |filename|
  puts filename
end
