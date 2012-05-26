require 'open-uri'
require 'shellwords'

# run df-misc scripts when a new DF release is announced
# downloads the binaries and save helper xmls

# usage: cd dev/df-structures ; git pull <reset commit> ; ruby ../df-misc/newrelease.rb

struct_path = '.'
misc_path = File.dirname(__FILE__)
tmp_path = File.expand_path("~/tmp/")
base_url = 'http://www.bay12games.com/dwarves/'

puts "read bay12 homepage"
page = open(base_url).read

# <a href="df_34_10_win_s.zip">Windows (No Music)</a><a href="df_34_10_linux.tar.bz2">Linux</a>
lin_binary_url = page[/<a href="(.*?)">linux<\/a>/i, 1]
win_binary_url = page[/<a href="(.*?)">windows \(no music\)<\/a>/i, 1]

puts "dl linux #{lin_binary_url}"
lin_tmp = File.join(tmp_path, 'tmp_df_lin')
Dir.mkdir(lin_tmp)
File.open(lin_tmp + '/' + lin_binary_url, 'w') { |fd| fd.write open(base_url + lin_binary_url).read }
puts "extracting"
Dir.chdir(lin_tmp) { system 'tar', 'xf', lin_binary_url }
lin_bin = File.join(lin_tmp, 'df_linux', 'libs', 'Dwarf_Fortress')

puts "dl windows #{win_binary_url}"
win_tmp = File.join(tmp_path, 'tmp_df_win')
Dir.mkdir(win_tmp)
File.open(win_tmp + '/' + win_binary_url, 'w') { |fd| fd.write open(base_url + win_binary_url).read }
puts "extracting"
Dir.chdir(win_tmp) { system 'unzip', '-q', win_binary_url }
win_bin = File.join(win_tmp, 'Dwarf Fortress.exe')

# TODO patch globals.xml directly
puts "lin_nextid"
lin_nextid = `ruby #{misc_path}/scan_nextid.rb #{lin_bin.shellescape}`
File.open('lin_nextid.xml', 'w') { |fd| fd.puts lin_nextid }

puts "lin_vtable"
lin_vtable = `ruby #{misc_path}/scan_linux_vtable.rb #{lin_bin.shellescape}`
File.open('lin_vtable.xml', 'w') { |fd| fd.puts lin_vtable }

puts "win_nextid"
win_nextid = `ruby #{misc_path}/scan_nextid.rb #{win_bin.shellescape}`
File.open('win_nextid.xml', 'w') { |fd| fd.puts win_nextid }

puts "win_patchmalloc"
system 'ruby', misc_path+'/df_patchmalloc.rb', win_bin

puts "done, archives extracted in #{tmp_path}/tmp_df_[lw]in"