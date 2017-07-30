#------------------------------------#
#              CAC ERRORS            #
#------------------------------------#
Errors={
	:ERR_NUMBER_TOO_LONG=>"Number too long!",
	:ERR_END_OF_COMMENT=>"End of comment expected.",
	:ERR_IDENT_TOO_LONG=>"Identifier too long.",
	:ERR_INVALID_CONSTANT_CHAR=>"Invalid char constant.",
	:ERR_INVALID_SYMBOL=>"Invalid symbol.",
	:ERR_INVALID_IDENT=>"An identifier expected.",
	:ERR_INVALID_CONSTANT=>"A constant expected.",
	:ERR_INVALID_TYPE=>"A type expected.",
	:ERR_INVALID_BASICTYPE=>"A basic type expected.",
	:ERR_INVALID_VARIABLE=>"A variable expected.",
	:ERR_INVALID_FUNCTION=>"A function identifier expected.",
	:ERR_INVALID_PROCEDURE=>"A procedure identifier expected.",
	:ERR_INVALID_PARAMETER=>"A parameter expected.",
	:ERR_INVALID_STATEMENT=>"Invalid statement.",
	:ERR_INVALID_COMPARATOR=>"A comparator expected.",
	:ERR_INVALID_EXPRESSION=>"Invalid expression.",
	:ERR_INVALID_DIM=>"Invalid number of dim array.",
	:ERR_INVALID_TERM=>"Invalid term.",
	:ERR_INVALID_FACTOR=>"Invalid factor.",
	:ERR_INVALID_LVALUE=>"Invalid lvalue in assignment.",	
	:ERR_INVALID_ARGUMENTS=>"Wrong arguments.",
	:ERR_TOO_MANY_PARAMS=>"Too many parameter .",
	:ERR_TOO_LESS_PARAMS=>"Too less parameter .",
	:ERR_NOT_FUNCTION=>"Unable using a function identifier here.",
	:ERR_NOT_ARRAY=>"Unable using a arrayVariable here.",
	:ERR_NO_PARAM=>"This function don't need any param.",
	:ERR_UNDECLARED_IDENT=>"Undeclared identifier.",
	:ERR_UNDECLARED_CONSTANT=>"Undeclared constant.",
	:ERR_UNDECLARED_INT_CONSTANT=>"Undeclared integer constant.",
	:ERR_UNDECLARED_TYPE=>"Undeclared type.",
	:ERR_UNDECLARED_VARIABLE=>"Undeclared variable.",
	:ERR_UNDECLARED_FUNCTION=>"Undeclared function.",
	:ERR_UNDECLARED_PROCEDURE=>"Undeclared procedure.",
	:ERR_DUPLICATE_IDENT=>"Duplicate identifier.",
	:ERR_TYPE_INCONSISTENCY=>"Type inconsistency",
	:ERR_INT_INCONSISTENCY=>"Type must be Integer.",
	:ERR_BASIC_INCONSISTENCY=>"Type must be Integer or Char.",
	:ERR_ARRAY_INCONSISTENCY=>"Type must be Array.",
	:ERR_PARAM_INCONSISTENCY=>"Param type inconsistency",	
	:ERR_EXPRESSION_INCONSISTENCY=>"Expression type inconsistency",
	:ERR_PARAMETERS_ARGUMENTS_INCONSISTENCY=>"The number of arguments and the number of parameters are inconsistent."
}
#------------------------------------#
#          CAC SYMBOL TOKEN          #
#------------------------------------#
SB_Tokens=[
	["+","SB_PLUS"],
	["-","SB_MINUS"],
	["*","SB_TIMES"],
	["/","SB_SLASH"],
	["=","SB_EQ"],
	[",","SB_COMMA"],
	[";","SB_SEMICOLON"],
	[")","SB_RPAR"],
	["!=","SB_NEQ"],
	[".","SB_PERIOD"],
	[".)","SB_RSEL"],
	[":","SB_COLON"],
	[":=","SB_ASSIGN"],
	["(","SB_LPAR"],
	["(.","SB_LSEL"],
	["<","SB_LT"],
	["<=","SB_LE"],
	[">","SB_GT"],
	[">=","SB_GE"]
]
#------------------------------------#
#        CAC KEYWORD TOKEN           #
#------------------------------------#
KW_Tokens=[
	["PROGRAM","KW_PROGRAM"],
	["CONST","KW_CONST"],
	["TYPE","KW_TYPE"],
	["VAR","KW_VAR"],
	["INTEGER","KW_INTEGER"],
	["CHAR","KW_CHAR"],
	["ARRAY","KW_ARRAY"],
	["OF","KW_OF"],
	["FUNCTION","KW_FUNCTION"],
	["PROCEDURE","KW_PROCEDURE"],
	["BEGIN","KW_BEGIN"],
	["END","KW_END"],
	["CALL","KW_CALL"],
	["IF","KW_IF"],
	["THEN","KW_THEN"],
	["ELSE","KW_ELSE"],
	["WHILE","KW_WHILE"],
	["DO","KW_DO"],
	["FOR","KW_FOR"],
	["TO","KW_TO"]
]
def find_token(str)
	SB_Tokens.each { |token|	return token if str==token[0] }	
	return nil
end#of find symbol token

class String
	def is_letter?
		/[a-zA-Z_]/.match self
	end
	def is_number?
		/[0-9]/.match self
	end
	def is_blank?
		/[ \t\r\n\f\v]/.match self
	end
	def is_const_char?
		/[ +\-*s\/=,;(<!>).:0-9a-zA-Z_]/.match(self) && self.size==3
	end
end
