#!/usr/bin/env ruby
require 'optparse'
require 'digest'

$options = { :directories => [ Dir.pwd ],
	     :threads => 1,
	     :recurse => false,
	     :recurse_depth => 0,
	     :scope => :local,
	     :crypto => Digest::MD5,
	     :delimited_print => false,
	     :keep => :old }

parse = OptionParser.new do |opts|
  opts.banner = "Usage: dupes.rb [options] [directories]"

  opts.on( '-c', '--crypto crypto', 'Hashing Function') do |crypto|
    sym = crypto.upcase.to_sym
    $options[:crypto] = Digest.const_missing sym
  end

  opts.on('-o', '--keep-oldest', 'Don\'t print oldest duplicates') do
    $options[:keep] = :old
  end

  opts.on('-y', '--keep-youngest', 'Don\'t print youngest duplicates') do
    $options[:keep] = :young
  end

  opts.on('-a', '--keep-all', 'Print all duplicates') do
    $options[:keep] = :all
  end

  opts.on('-h', '--help', 'Shows Help') do
    puts opts
    exit
  end
end

parse.parse!

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
  end
end.flatten

case $options[:keep]
when :old
  dupe_filenames = dupe_filenames.drop(1)
when :young
  dupe_filenames = dupe_filenames[0...-1]
when :all
  # do nothing
end


dupe_filenames.each do |filename|
  puts filename
end
