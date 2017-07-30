load 'token.rb'
load 'parse.rb'
load 'scan.rb'
load 'symtab.rb'
load 'semantics.rb'
load 'codegen.rb'
load 'instructions.rb'
def dich_mot_folder
	input_folder=ARGV[0]
	output_folder= ARGV[1] || "hungnd"	
	Dir.mkdir(output_folder) unless File.exists?(output_folder)
	if File.exists?(input_folder)
		if ARGV[2]=="w"
			Dir.foreach(input_folder) do |filename|				
				if filename.end_with?(".kpl")||filename.end_with?(".KPL")				
					input_filename="#{input_folder}\\#{filename}"
					output_filename="#{output_folder}\\result_#{filename[0..-5]}.txt"
					puts "Compile #{filename} => result_#{filename[0..-5]}.txt"		
					begin
					process(input_filename,output_filename,"w")
					rescue Exception => msg
							p msg						
					end		
				end
			end
		else
			output_filename="#{output_folder}\\result_hungnd.txt"			
			Dir.foreach(input_folder) do |filename|
				if filename.end_with?(".kpl")||filename.end_with?(".KPL")				
					input_filename="#{input_folder}\\#{filename}"
					puts "Compile #{filename} => result_hungnd.txt"
					begin
					process(input_filename,output_filename)
					rescue Exception => msg
							p msg						
					end
				end
			end
		end
	else
		puts "IO_ERROR! Can't open input folder !"
	end
end
def dich_mot_file
	input_filename=ARGV[0]	
	output_filename="result_#{ARGV[0].split("\\").last[0..-5]}.txt"
	if File.exists?(input_filename)
		puts "Compile #{input_filename} => #{output_filename}"
		if ARGV[1]=="w"
			begin
				process(input_filename,output_filename,"w")
			rescue Exception => msg
				p msg						
			end	
		else			
			begin
				process(input_filename,output_filename)
			rescue Exception => msg
				p msg						
			end
		end					
	else
		puts "IO_ERROR! Can't open input file !"
	end
end
def start(input_filename,output_filename,option)
		@symtab={}			
		@position=[1,0]		
		@input_file = File.new(input_filename, "r") if File.exist?(input_filename)
		@output_file = File.new(output_filename, option)
		@out_file=File.new("#{input_filename[0..-5]}_r","wb")
		if @input_file && @output_file
			read_one_char
			return true
		else
			puts "IO_ERROR!"
			return false
		end
end
def finish
	@input_file.close
	@output_file.close
end
def process (input_filename,output_filename,option="a")		
		if start(input_filename,output_filename,option)
			ten_file=input_filename.split("\\").last
			@output_file.write "Start compile file \"#{ten_file.upcase}\"...\n"					
			@stop=false						
			@currentToken=nil
			@nextToken=getToken
			initCodeBuffer
			initSymTab
			compileProgram			
			printCodeBlock(@codeBlock[:code]) unless @stop==true
			@output_file.write "...finish compile file \"#{ten_file.upcase}\".\
			\n=====================================\n\n\n\
			\n=====================================\n"
			finish				
		else
			puts "Can't open input, output file!"			
		end
end#of def process
if ARGV[0]
	if ARGV[0].end_with?(".kpl")||ARGV[0].end_with?(".KPL")
		dich_mot_file
	else
		dich_mot_folder
	end	
else
	print"Syntax of command : name1 [name2] [option]\n"
	print"	name1: input_file or input_folder \
		\n	name2: output_folder (if name1 is folder), default is \"hungnd\"\
			Ex1: test result\
		\n 	Ex2: test result w\
		\n 	Ex3: example1.kpl \
		\n	Ex4: example1.kpl w \n"
	puts "No input file or folder!"
end


