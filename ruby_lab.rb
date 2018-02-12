
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
	
	out.gsub!(/[\?¿\!¡\.;&@%#\|]/, "")  # Remove funky characters.
	
	unless out[/[^\d\s\w\']/].nil?  # If it has anything other than whitespace, characters, digits, and apostrophes, get rid of it.
		return nil
	end
	
	out.downcase!  # Lower case everything.
	
	out.squeeze!(" ")  # Remove excess spaces.
	
	return out
end

def mcw(word)
	bigNum = 0  # Most instances of a following word.
	bigWord = ""  # Word representing the above number.
	if not $bigrams.has_key?(word)  # If the word doesn't exist, ignore it.
		return bigWord
	end
	$bigrams[word].each do |k, v|  # For every word that follows the passed one...
		if v > bigNum  # If it appears more than the current maximum, replace the max with this word.
			unless ["a", "an", "and", "by", "for", "from", "in", "of", "on", "or", "out", "the", "to", "with"].include? k
				bigNum = v
				bigWord = k
			end
		end
	end
	return bigWord
end

def create_title(startingWord)
	name = [startingWord]  # Array of words that will make up the song title.
	words = 1
	curWord = startingWord
	while curWord.length() > 0 && $bigrams.has_key?(curWord)  # If the current word exists...
		most = mcw(curWord)
		if name.include? most  # If the most common word will be a repeat, return the title as-is.
			return name.join(" ").strip
		end
		name << most  # Append the most common word onto the growing title.
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
					word = word.split(" ")  # Split the title based on words
					for i in 0..(word.length()-2)  # For every word in the title (except the very last)...
						if $bigrams.has_key?(word[i])  # If the word isn't in the dataset, add it. Otherwise...
							if $bigrams[word[i]].has_key?(word[i+1])  # If the following word isn't attached to the current one, add it. Otherwise increment.
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
	rescue
		STDERR.puts "Could not open file"
		exit 4
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
		w = $stdin.gets.chomp.downcase  # Minor input cleaning.
		
	end
end

if __FILE__==$0
	main_loop()
end
