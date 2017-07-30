def file_compare(filename1,filename2)
	line=1
	f1 = File.new(filename1, "r")
	f2 = File.new(filename2, "r")
	character=f1.getc	
	while character do
			line+=1 if character=="\n"
			break if character!=f2.getc
			character=f1.getc				
	end
	if character || f2.getc
		puts "Different at line #{line}!\n"		
	else
		puts "Is the same file.\n"
	end
	f1.close
	f2.close	
	return 1	
end