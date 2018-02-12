
#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Christopher McCabe
# christopherdentist@gmail.com
#
###############################################################

$bigrams = Hash.new # The Bigram data structure
$name = "Christopher McCabe"

def cleanup_title(line)
	title = line.chomp.split(/<SEP>/)[3]
	if title.nil?
		return nil
	end
	out = title.gsub(/\(.*\)/, "")  # Remove ()
	out.gsub!(/\[.*/, "")  # Remove [*]
	out.gsub!(/\{.*/, "")  # Remove {*}
	out.gsub!(/\\.*/, "")  # Remove \*\
	out.gsub!(/\/.*/, "")  # Remove /*/
	out.gsub!(/_.*/, "")  # Remove _*_
	out.gsub!(/\-.*/, "")  # Remove -*-
	out.gsub!(/:.*/, "")  # Remove :*:
	out.gsub!(/\".*/, "")  # Remove "*"
	out.gsub!(/`.*/, "")  # Remove `*`
	out.gsub!(/\+.*/, "")  # Remove +*+
	out.gsub!(/=.*/, "")  # Remove =*=
	out.gsub!(/\*.*/, "")  # Remove ***
	out.gsub!(/(feat\.).*/, "")  # Remove feat.
	
	out.gsub!(/[\?¿\!¡\.;&@%#\|]/, "")
	
	unless out[/[^\d\s\w\']/].nil?
		return nil
	end
	
	out.downcase!
	
	out.squeeze!(" ")
	
	return out
	#p out
end

def mcw(word)
	bigNum = 0
	bigWord = ""
	if not $bigrams.has_key?(word)
		return bigWord
	end
	$bigrams[word].each do |k, v|
		if v > bigNum
			unless ["a", "an", "and", "by", "for", "from", "in", "of", "on", "or", "out", "the", "to", "with"].include? k
				bigNum = v
				bigWord = k
			end
		end
	end
	return bigWord
end

def create_title(startingWord)
	name = [startingWord]
	words = 1
	curWord = startingWord
	while curWord.length() > 0 && $bigrams.has_key?(curWord)
		most = mcw(curWord)
		if name.include? most
			return name.join(" ").strip
		end
		name << most
		curWord = most
	end
	return name.join(" ").strip
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	begin
		if RUBY_PLATFORM.downcase.include? 'mswin'
			file = File.open(file_name)
			unless file.eof?
				file.each_line do |line|
					# do something for each line (if using windows)
					cleanup_title(line)
				end
			end
			file.close
		else
			IO.foreach(file_name, encoding: "utf-8") do |line|
				# do something for each line (if using macos or linux)
				word = cleanup_title(line)
				unless word.nil?
					word = word.split(" ")
					for i in 0..(word.length()-2)
						if $bigrams.has_key?(word[i])
							if $bigrams[word[i]].has_key?(word[i+1])
								$bigrams[word[i]][word[i+1]] += 1
							else
								$bigrams[word[i]][word[i+1]] = 1
							end
						else
							$bigrams[word[i]] = Hash.new(0)
						end
					end
				end
			end
		end

		puts "Finished. Bigram model built.\n"
	#rescue
	#	STDERR.puts "Could not open file"
	#	exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
	print "Enter a word [Enter 'q' to quit]: "
	w = $stdin.gets.chomp.downcase
	while w != 'q'
		unless $bigrams.has_key?(w)
			p "Please pick a different word."
		else
			p create_title(w)
		end
		print "Enter a word [Enter 'q' to quit]: "
		w = $stdin.gets.chomp.downcase
		
	end
end

if __FILE__==$0
	main_loop()
end
