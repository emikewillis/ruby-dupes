#!/usr/bin/env ruby
require 'digest/md5'

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
  print filename + ' '
end
