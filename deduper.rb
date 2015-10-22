#!/usr/bin/env ruby
require 'optparse'
require 'digest'
require 'pry'

$options = { :directories => [ Dir.pwd ],
	     :threads => 1,
	     :recurse => false,
	     :recurse_depth => -1,
	     :scope => :local,
	     :crypto => Digest::MD5,
	     :delimited_print => false,
	     :keep => :old,
	     :read_hidden => false }

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

  opts.on('-A', '--keep-all', 'Print all duplicates') do
    $options[:keep] = :all
  end

  opts.on('-h', '--help', 'Shows Help') do
    puts opts
    exit
  end

  opts.on('-G', '--global', 'Detect duplicates across all folders') do
    $options[:scope] = :global
  end

  opts.on('-L', '--local', 'Detect duplicates for each directory seperately') do
    $options[:scope] = :local
  end

  opts.on('-a', '--all', 'Read hidden files and folders') do
    $options[:read_hidden] = true 
  end

  opts.on('-r', '--recurse', 'Descend into sub-directories') do
    $options[:recurse] = true 
  end

  opts.on( '-d', '--depth depth', 'How many subdirectories deep to search. -1 for no limit (default)') do |depth|
    $options[:recurse_depth] = depth.to_i
  end
end

parse.parse!

# Features to add:
# arguments used as a list of directories
# -X num_of_threads multi-threaded checksumming
# -R descend into directories to find dupes
# -r max_depth
# -l -g or --local --global  option to check for dupes between all directories or only within a directory
# -flist option to dump delimited lists of matching files

files = {}
directories = ARGV
if directories.empty?
  directories << Dir.pwd + '/'
end

directories.map! do |dirname|
  File.expand_path(dirname)
end.map! do |dir|
  unless File.ftype(dir) == 'directory'
    puts "#{dir} is not a directory. Aborting."
    abort
  end

  Dir.chdir dir

  Dir.entries(dir).select do |fname| 
    fname != '.' and fname != '..' and (fname[0] != '.' ? true : $options[:read_hidden])
  end.map do |fn|
    fn = File.expand_path(fn)
    {:fname => fn,
     :type  => File.ftype(fn)}
  end
end

unless $options[:recurse]
  directories.map! do |directory|
    directory.select do |entry|
      entry[:type] == 'file'
    end
  end
end

directories.each{|d| d.each {|f| puts f[:fname] }}
p directories
exit

# Build a hashmap of hashes and filenames of files with matching hashes
Dir['*'].each do |filename|
  #chksm = Digest::MD5.hexdigest(File.read(filename))
  chksm  = 0
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
