MAX_IDENT_LEN=15
MAX_NUMBER_VAL=4294967296

	def read_one_char
			@char=@input_file.getc
			@last_position=Array.new(@position)	
			if @char=="\n"
				@position[0]+=1
				@position[1]=0
				@last_position
			else
				@position[1]+=1
			end	
	end#of read_one_char
	def read_while #stop at character invalid
		tmp=""
		begin
			tmp += @char 
			read_one_char
		end while @char && yield(tmp)
		return tmp
	end#of read_while
	def read_until str #stop at end of str	or @char==nil	
		tmp=@char					
		while @char && !tmp.include?(str) do
			read_one_char			
			tmp+= @char if @char									
		end
		return tmp
	end#of read_while	
#------------------------------------#
#          GET TOKEN FUNCTION        #
#------------------------------------#
	def get_Identy_Keyword_at position	
		str=read_while {@char.is_letter?||@char.is_number?}
		if str.size>MAX_IDENT_LEN
			return [position, "TK_NONE", Errors[:ERR_IDENT_TOO_LONG]]
		else	
			tmp_type=nil
			KW_Tokens.each { |keyword| tmp_type=keyword[1] if str.upcase==keyword[0] }		
			if tmp_type
				return [position, tmp_type, nil]
			else
				return [position, "TK_IDENT", str.upcase]
			end
		end	
	end# get_Identy_Keyword_at
	def get_Number_at position	
		str=read_while {@char.is_number?}
		if str.to_i<=MAX_NUMBER_VAL
			return [position, "TK_NUMBER", str.to_i]
		else
			return [position, "TK_NONE", Errors[:ERR_NUMBER_TOO_LONG]]
		end
	end#of digit token
	def	get_Const_Char_at position 	
		str=@char
		read_one_char
		str+=read_until "'"
		if @char==nil
			return [position, "TK_NONE", Errors[:ERR_INVALID_CONSTANT_CHAR]]
		else
			if str.is_const_char?		#tuc la str co dang: 'x'		
				read_one_char
				return [position, "TK_CHAR", str]
			else
				return [position, "TK_NONE", Errors[:ERR_INVALID_CONSTANT_CHAR]]
			end		
		end
	end#of get_Const_Char_at
	def get_Symbol_at position
		tmp=@char
		tmp_token=find_token(tmp)
		read_one_char
		if @char
			tmp += @char
			case tmp
			when "(*"
				return skip_comment position										 
			else
				tmp_token=find_token(tmp) if find_token(tmp)
				read_one_char if find_token(tmp)
			end		
		end	
		if tmp_token
			return [position, tmp_token[1], nil]		
		else		
			return [position, "TK_NONE", Errors[:ERR_INVALID_SYMBOL]]		
		end	
	end#of get_Symbol_at
	
#------------------------------------#
#       SKIP COMMENT && BLANK        #
#------------------------------------#
	def skip_comment position
		read_one_char # doc bo qua ki tu * cua (*
		read_until "*)"
		return [@position, "TK_NONE", Errors[:ERR_END_OF_COMMENT]] unless @char
		read_one_char if @char
		return getToken
	end#of skip comment
	def skip_blank
		read_one_char while @char&&@char.is_blank?
	end#of skip_blank
	
#------------------------------------#
#          GET A TOKEN FROM FILE     #
#------------------------------------#
def getToken	
	position=Array.new(@position)
	return [position,"TK_END",Errors[:ERR_END_OF_COMMENT]] if @char==nil		
				case @char
					when /[a-zA-Z_]/		
					  	return get_Identy_Keyword_at position		  	
					when /[0-9]/
					  	return get_Number_at position			  
					when /[ \t\r\n\f\v]/
					  	skip_blank
					  	return getToken	  	
					when /[+\-*\/=,;(<!>).:]/
						return get_Symbol_at position
					when /[']/		
						return get_Const_Char_at position		
					else		  	
					  	return [position,"TK_NONE",Errors[:ERR_INVALID_SYMBOL]]
					end
end	#of getToken
