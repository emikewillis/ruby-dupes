require 'digest/md5'

#unless ARGV.size > 0
#  print "Operate on current directory <#{Dir.pwd}>? (Y/n) "
#  unless gets.chomp == 'Y'
#    abort
#  end
#  ARGV << Dir.pwd
#end

files = {}

Dir['*.*'].each do |filename|
  chksm = Digest::MD5.hexdigest(File.read(filename))
  unless files[chksm]
    files[chksm] = []
  end
  files[chksm] << filename
end

files.select do |k,v|
  v.size > 1
end.each do  |k,v|
  puts "Hash #{k} is shared by the files:"
  v.each_with_index do |filename,i|
    puts "(#{i+1}) #{filename}"
  end
end
