def eat(tokenType)  
  return 0 if @stop
  if (@nextToken[1] == tokenType)      
      @currentToken = @nextToken
      @nextToken = getToken
  else 
      missToken(@nextToken[0],tokenType,@nextToken[1])      
  end  
end

def compileProgram
  return 0 if @stop

  eat("KW_PROGRAM")  
  obj = createObject("OBJ_PROGRAM")
  enterBlock(obj[:scope]) if obj
  eat("SB_SEMICOLON")
  compileBlock      
  eat("SB_PERIOD")
  gen("HL")
  exitBlock 
end

def compileConstDecls
  return 0 if @stop
  
  if (@nextToken[1] == "KW_CONST")
    eat("KW_CONST")
    begin      
      obj = createObject("OBJ_CONSTANT")
      eat("SB_EQ")      
      obj[:type] = compileConstant if obj
      declareObject(obj)      
      eat("SB_SEMICOLON")
    end while (@nextToken[1] == "TK_IDENT")  
  end  
end

def compileTypeDecls
  return 0 if @stop
  
  if (@nextToken[1] == "KW_TYPE")
    eat("KW_TYPE")
    begin      
      obj = createObject("OBJ_TYPE")
      eat("SB_EQ")      
      obj[:type] = compileType if obj
      declareObject(obj)
      eat("SB_SEMICOLON")
    end while (@nextToken[1] == "TK_IDENT")    
  end
end

def compileVarDecls
  return 0 if @stop
  
  if (@nextToken[1] == "KW_VAR")
    eat("KW_VAR")
    begin      
      obj = createObject("OBJ_VARIABLE")
      eat("SB_COLON")            
      obj[:type] = compileType if obj
      declareObject(obj)      
      eat("SB_SEMICOLON")
    end while (@nextToken[1] == "TK_IDENT")     
  end  
end

def compileBlock
  return 0 if @stop

  jmp = gen("J")
  compileConstDecls
  compileTypeDecls
  compileVarDecls
  compileSubDecls    
  updateJ(jmp,getCurrentCodeAddress)    
  gen("INT",@symtab[:currentScope][:frameSize])
  eat("KW_BEGIN")
  compileStatements
  eat("KW_END")
end

def compileSubDecls
  return 0 if @stop
  
  while ((@nextToken[1] == "KW_FUNCTION") || (@nextToken[1] == "KW_PROCEDURE"))
    if (@nextToken[1] == "KW_FUNCTION")
      compileFuncDecl
    else
      compileProcDecl
    end
  end
end

def compileFuncDecl
  return 0 if @stop
  
  eat("KW_FUNCTION")  
  obj = createObject("OBJ_FUNCTION")
  declareObject(obj)
  enterBlock(obj[:scope]) if obj
  compileParams
  eat("SB_COLON")  
  obj[:type] = compileBasicType if obj
  eat("SB_SEMICOLON")
  compileBlock
  gen("EF")
  eat("SB_SEMICOLON")
  exitBlock  
end

def compileProcDecl
  return 0 if @stop
  
  eat("KW_PROCEDURE")  
  obj = createObject("OBJ_PROCEDURE")
  declareObject(obj)
  enterBlock(obj[:scope]) if obj
  compileParams
  eat("SB_SEMICOLON")
  compileBlock
  gen("EP")
  eat("SB_SEMICOLON")
  exitBlock  
end

def compileUnsignedConstant
  return 0 if @stop
  
  case (@nextToken[1])
    when "TK_NUMBER"
      eat("TK_NUMBER")
      return makeIntConstant(@currentToken[2].to_i)
    when "TK_IDENT"
      eat_declared_ident_type "CONSTANT"
      return obj[:type].dup     
    when "TK_CHAR"
      eat("TK_CHAR")
      return makeCharConstant(@currentToken[2].to_i)
    else
      error(@nextToken[0],"ERR_INVALID_CONSTANT")          
    end  
end

def compileConstant
  return 0 if @stop  

  case (@nextToken[1])
    when "SB_PLUS"
      eat("SB_PLUS")      
      type = compileConstant2
    when "SB_MINUS"
      eat("SB_MINUS")      
      type = compileConstant2
      type[:intValue] = - type[:intValue]
    when "TK_CHAR"
      eat("TK_CHAR")
      type = makeCharConstant(@currentToken[2])
    else      
      type = compileConstant2
    end
  return type
end

def compileConstant2
  return 0 if @stop
  
  case (@nextToken[1])
    when "TK_NUMBER"
      eat("TK_NUMBER")
      return makeIntConstant(@currentToken[2].to_i)
    when "TK_IDENT"      
      obj = eat_declared_ident_type "CONSTANT"
      if obj[:type][:typeClass]=="TP_INT"
          return obj[:type].dup
      else
          error(@nextToken[0],"ERR_UNDECLARED_INT_CONSTANT")          
      end         
    else
      error(@nextToken[0],"ERR_INVALID_CONSTANT")      
    end  
end

def compileType
  return 0 if @stop
  
  case (@nextToken[1])
    when "KW_INTEGER"      
      eat("KW_INTEGER")
      type = makeIntType
    when "KW_CHAR"      
      eat("KW_CHAR")
      type = makeCharType
    when "KW_ARRAY"
      eat("KW_ARRAY")
      eat("SB_LSEL")
      eat("TK_NUMBER")
      type = makeArrayType(@currentToken[2].to_i, {})
      eat("SB_RSEL")
      eat("KW_OF")      
      type[:elementType] = compileType
      
    when "TK_IDENT"      
      obj=eat_declared_ident_type "TYPE"
      type = obj[:type].dup       
    else
      error(@nextToken[0],"ERR_INVALID_TYPE")    
    end
  return type
end

def compileBasicType
  return 0 if @stop
  
  case (@nextToken[1])
    when "KW_INTEGER"
      eat("KW_INTEGER")
      type = makeIntType
    when "KW_CHAR"
      eat("KW_CHAR")
      type = makeCharType    
    else
      error(@nextToken[0],"ERR_INVALID_BASICTYPE")    
    end
  return type
end

def compileParams
  return 0 if @stop

  if (@nextToken[1] == "SB_LPAR")
    eat("SB_LPAR")
    compileParam
    while (@nextToken[1] == "SB_SEMICOLON")
      eat("SB_SEMICOLON")
      compileParam
    end
    eat("SB_RPAR")
  end
end

def compileParam
  return 0 if @stop
  
  case (@nextToken[1])
    when "TK_IDENT"   
      paramkind= "PARAM_VALUE"            
    when "KW_VAR"
      eat("KW_VAR")      
      paramkind= "PARAM_REFERENCE"
    else
      error(@nextToken[0],"ERR_INVALID_PARAMETER")
      return nil   
  end
  return 0 if @stop
  obj = createObject("OBJ_PARAMETER",paramkind, @symtab[:currentScope][:owner])  
  eat("SB_COLON")      
  obj[:type] = compileBasicType if obj
  declareObject(obj)  
end

def compileStatements
  return 0 if @stop

  compileStatement  
  while ( @nextToken[1] == "SB_SEMICOLON")
    eat("SB_SEMICOLON")
    compileStatement
  end
end

def compileStatement
  return 0 if @stop

  case (@nextToken[1])
  when "TK_IDENT"
    compileAssignSt    
  when "KW_CALL"
    compileCallSt    
  when "KW_BEGIN"
    compileGroupSt    
  when "KW_IF"
    compileIfSt   
  when "KW_WHILE"
    compileWhileSt    
  when "KW_FOR"
    compileForSt    
  when "SB_SEMICOLON","KW_END","KW_ELSE"  
  else
    error(@nextToken[0],"ERR_INVALID_STATEMENT")    
  end
end

def compileLValue
  return 0 if @stop
  
  obj = eat_declared_ident
  return 0 if @stop
  case obj[:kind]
      when "OBJ_FUNCTION"            
            genRA(obj)
            error(@currentToken[0],"ERR_NOT_FUNCTION") if obj!=@symtab[:currentScope][:owner]        
            tmp= obj[:type]
      when "OBJ_VARIABLE"
            genAddress(obj)
          if obj[:type][:typeClass]=="TP_ARRAY"
                tmp= compileIndexes (obj[:type])
          else
                tmp= obj[:type]
          end    
      when "OBJ_PARAMETER"
            if(obj[:paramkind]=="PARAM_REFERENCE")                
                genValue(obj)                      
            else
                genAddress(obj)
            end
            tmp= obj[:type]
      else            
            error(@currentToken[0],"ERR_INVALID_LVALUE")
  end
  return tmp
end

def compileAssignSt
  return 0 if @stop
  
  leftType=compileLValue
  eat("SB_ASSIGN")
  rightType=compileExpression
  checkTypeEquality(leftType, rightType, "EXPRESSION")
  gen("ST")
end

def compileCallSt
  return 0 if @stop
  
  eat("KW_CALL")
  obj= eat_declared_ident_type "PROCEDURE"

  if isPredefined(obj)
    compileArguments(obj[:paramList]) if obj!={}
    genPredefined(obj)
  else
    gen("INT",4)
    compileArguments(obj[:paramList]) if obj!={}
    gen("DCT",4 + obj[:paramCount])
    genCall(obj)
  end
end

def compileGroupSt
  return 0 if @stop
  
  eat("KW_BEGIN")
  compileStatements
  eat("KW_END")  
end

def compileIfSt
  return 0 if @stop
  
  eat("KW_IF")
  compileCondition    
  eat("KW_THEN")
    fj = gen("FJ")
  compileStatement
  
  if (@nextToken[1] == "KW_ELSE")

      j = gen("J")
      updateJ(fj, getCurrentCodeAddress)

    eat("KW_ELSE")
    compileStatement
      updateJ(j, getCurrentCodeAddress)
  else
    updateJ(fj, getCurrentCodeAddress)
  end   
end

def compileWhileSt
  return 0 if @stop

  mark=getCurrentCodeAddress
  eat("KW_WHILE")
  compileCondition
    fj=gen("FJ")
  eat("KW_DO")
  compileStatement
    gen("J",mark)
    updateJ(fj, getCurrentCodeAddress) 
end

def compileForSt
  return 0 if @stop
  
  eat("KW_FOR")  
  obj= eat_declared_ident_type "VARIABLE"  
  error(@currentToken[0],"ERR_NOT_ARRAY") if (obj[:type] && obj[:type][:typeClass]=="TP_ARRAY")
    genAddress(obj)
    gen("CV")
  varType= obj[:type]
  eat("SB_ASSIGN")

  expType=compileExpression
    gen("ST")
  checkTypeEquality(varType, expType, "EXPRESSION")
  eat("KW_TO")
    mark=getCurrentCodeAddress
    gen("CV")
    gen("LI")
  expType=compileExpression    
  checkTypeEquality(varType, expType, "EXPRESSION")
    gen("LE")
    fj=gen("FJ")
  eat("KW_DO")
  compileStatement
    gen("CV")  
    gen("CV")
    gen("LI")
    gen("LC",1)
    gen("AD")
    gen("ST")
    gen("J",mark)
    updateJ(fj, getCurrentCodeAddress)
    gen("DCT",1)
end

def compileArgument param
  return 0 if @stop
  
  if param[:paramkind] == "PARAM_VALUE"
        type = compileExpression            
  else        
        obj = eat_declared_ident
        return 0 if @stop
        case obj[:kind]
            when "OBJ_VARIABLE","OBJ_PARAMETER"                
                genAddress(obj)
                if obj[:type][:typeClass]=="TP_ARRAY"
                      type= compileIndexes (obj[:type])
                else
                      type= obj[:type]
                end                                          
            else            
                error(@currentToken[0],"ERR_INVALID_PARAMETER")
        end         
  end
  checkTypeEquality(type, param[:type],"PARAM")
end

def compileArguments paramList
  return 0 if @stop

  case (@nextToken[1])
    when "SB_LPAR"
      if paramList==nil || paramList==[]
        return error(@currentToken[0],"ERR_NO_PARAM")        
      else
        eat("SB_LPAR")        
        paramList.each do |param|
          if @nextToken[1]=="SB_RPAR"
            return error(@currentToken[0],"ERR_TOO_LESS_PARAMS")             
          end
          compileArgument(param)          
          eat("SB_COMMA") unless param==paramList.last
        end
        
        if @nextToken[1]=="SB_COMMA"
          return error(@currentToken[0],"ERR_TOO_MANY_PARAMS")          
        else
          eat "SB_RPAR"
        end  
      end  
    when "SB_TIMES","SB_SLASH","SB_PLUS","SB_MINUS","KW_TO","KW_DO","SB_RPAR","SB_COMMA","SB_EQ","SB_NEQ","SB_LE","SB_LT","SB_GE","SB_GT","SB_RSEL","SB_SEMICOLON","KW_END","KW_ELSE","KW_THEN"
      if paramList==nil || paramList==[]        
      else                  
          return error(@currentToken[0],"ERR_TOO_LESS_PARAMS")
      end  
    else
      return error(@nextToken[0],"ERR_INVALID_ARGUMENTS")
  end
end

def compileCondition
  return 0 if @stop

  leftExp = compileExpression
  checkType(leftExp, "BASIC")  
  case (@nextToken[1])
    when "SB_EQ","SB_NEQ","SB_LE","SB_LT","SB_GE","SB_GT"    
      eat @nextToken[1]
      tmp="#{@currentToken[1][3..4]}"
    else
      return error(@nextToken[0],"ERR_INVALID_COMPARATOR")
  end
  rightExp = compileExpression
  checkType(leftExp, "BASIC")
  checkTypeEquality(leftExp, rightExp, "EXPRESSION")
  gen(tmp)
end

def compileExpression
  return 0 if @stop
  
  case (@nextToken[1])
  when "SB_PLUS","SB_MINUS"    
    eat @nextToken[1]
    type = compileExpression2
    checkType(type, "INT")
    gen("NEG") if @currentToken[1]=="SB_MINUS"  
    return type  
  else
    return compileExpression2
  end    
end

def compileExpression2
  return 0 if @stop
  type = compileTerm 
  type = compileExpression3(type)  
  return type
end

def compileExpression3(type)
  return 0 if @stop

  case (@nextToken[1])
  when "SB_PLUS"
    eat @nextToken[1]
    checkType(type, "INT")     
    type1 = compileTerm
    checkType(type1, "INT")
    gen("AD")      
    return compileExpression3(type)
  when "SB_MINUS"
    eat @nextToken[1]
    checkType(type, "INT")     
    type1 = compileTerm
    checkType(type1, "INT")
    gen("SB")      
    return compileExpression3(type)  
  when "KW_TO","KW_DO","SB_RPAR","SB_COMMA","SB_EQ","SB_NEQ","SB_LE","SB_LT","SB_GE","SB_GT","SB_RSEL","SB_SEMICOLON","KW_END","KW_ELSE","KW_THEN"
    return type
  else
    error(@nextToken[0],"ERR_INVALID_EXPRESSION")
  end
end
def compileTerm
  return 0 if @stop
  type=compileFactor  
  type=compileTerm2(type)  
  return type
end

def compileTerm2 type
  return 0 if @stop

  case (@nextToken[1])
    when "SB_TIMES"
      eat @nextToken[1]
      checkType(type, "INT")     
      type2 = compileFactor
      checkType(type2, "INT") 
      gen("ML")
      return compileTerm2(type)
    when "SB_SLASH"
      eat @nextToken[1]
      checkType(type, "INT")     
      type2 = compileFactor
      checkType(type2, "INT")
      gen("DV") 
      return compileTerm2(type)  
    when "SB_PLUS","SB_MINUS","KW_TO","KW_DO","SB_RPAR","SB_COMMA","SB_EQ","SB_NEQ","SB_LE","SB_LT","SB_GE","SB_GT","SB_RSEL","SB_SEMICOLON","KW_END","KW_ELSE","KW_THEN"
      return type
    else
      error(@nextToken[0],"ERR_INVALID_TERM")
  end
end

def compileFactor
  return 0 if @stop

  case (@nextToken[1])
    when "TK_NUMBER"
      eat("TK_NUMBER")
      gen("LC",@currentToken[2])
      return makeIntType  
    when "TK_CHAR"
      eat("TK_CHAR")
      gen("LC",@currentToken[2][1].ord)              
      return makeCharType     
    when "TK_IDENT"      
      obj = eat_declared_ident
      case obj[:kind]
        when "OBJ_VARIABLE"

          if  obj[:type][:typeClass] == "TP_ARRAY"            
            genAddress(obj)
            type = compileIndexes(obj[:type])
            gen("LI")            
            return type
          else
            genValue(obj)
            return obj[:type]
          end                  
        when "OBJ_CONSTANT"
          if obj[:type][:typeClass]=="TP_INT"
            gen("LC", obj[:type][:intValue])            
            return makeIntType
          else
            gen("LC", obj[:type][:charValue])
            return makeCharType
          end
        when "OBJ_PARAMETER"
          if(obj[:paramkind]=="PARAM_REFERENCE")                
                genValue(obj)
                gen "LI"             
                type= obj[:type]                
            else
                genValue(obj)             
                type= obj[:type]
            end          
          return type
        when "OBJ_FUNCTION"      
          
          if (isPredefined(obj))
            compileArguments(obj[:paramList])           
            genPredefined(obj)
          else
            gen("INT",4)
            compileArguments(obj[:paramList])
            gen("DCT",4 + obj[:paramCount])
            genCall(obj)
          end
          type = obj[:type]
          return type
        else 
          error(@currentToken[0],"ERR_INVALID_FACTOR") unless obj=={}               
      end
    when "SB_LPAR"
      eat "SB_LPAR"
      type=compileExpression
      eat "SB_RPAR"
      return type
    else
      error(@nextToken[0],"ERR_INVALID_FACTOR")
    end
end

def compileIndexes arrayType
  return 0 if @stop

  while (@nextToken[1] == "SB_LSEL")
    return 0 if @stop
    # co van de khi dung sai so chieu cua mang
    eat("SB_LSEL")    
    checkType(compileExpression, "INT")    
    checkType(arrayType, "ARRAY")            
    arrayType = arrayType[:elementType] unless arrayType==nil    
    if(arrayType[:typeClass]=="TP_ARRAY")
      gen("LC",sizeOfType(arrayType))
      gen("ML")
    end
    gen("AD")
    eat("SB_RSEL")
    error(@nextToken[0],"ERR_INVALID_DIM") if (@nextToken[1] == "SB_LSEL" && arrayType[:typeClass]!="TP_ARRAY") 
  end  
  checkType(arrayType, "BASIC")
  return arrayType
end

def error(position,err)
  @output_file.write "#{position[0]}-#{position[1]}:ERROR!(#{Errors[err.to_sym]})\n"
  @stop=true 
end
def missToken(position,need,meet)
  @output_file.write "#{position[0]}-#{position[1]}:ERROR!(Need token #{need} but meet token #{meet})\n"
  @stop=true
end