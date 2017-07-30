
def makeIntType   
  {:typeClass=>"TP_INT"}
end

def makeCharType   
  {:typeClass=>"TP_CHAR"}
end

def makeArrayType(arraySize, elementType)
  {:typeClass=>"TP_ARRAY",:arraySize=>arraySize,:elementType=>elementType.dup} if elementType!=nil
end

def compareType(type1, type2)
  type1==type2
end

def makeIntConstant(i)  
  {typeClass:"TP_INT",intValue:i}
end

def makeCharConstant(ch)
  {typeClass:"TP_CHAR",charValue:ch}
end

def createScope(owner, outer)  
  {objList:[],owner:owner,outer:outer,frameSize: RESERVED_WORDS}  
end

def createObject(kind, paramkind=nil, owner=nil)
  return 0 if @stop
  eat "TK_IDENT"
  name=@currentToken[2]
  if findObject(@symtab[:currentScope][:objList], name)=={}
    obj={name:name,kind:kind}
    case kind
      when "OBJ_PROGRAM"
        obj[:scope]=createScope(obj,nil)
        obj[:codeAddress] = getCurrentCodeAddress
        @symtab[:program] = obj
      when "OBJ_VARIABLE"      
        obj[:localOffset] = 0
        obj[:scope]= createScope(obj, @symtab[:currentScope])
      when "OBJ_FUNCTION", "OBJ_PROCEDURE"
        obj[:paramCount] = 0
        obj[:codeAddress] = getCurrentCodeAddress
        obj[:scope]= createScope(obj, @symtab[:currentScope])     
      when "OBJ_PARAMETER"
        obj[:paramkind]=paramkind
        obj[:owner]=owner
        obj[:localOffset] = 0  
      when "OBJ_CONSTANT","OBJ_TYPE"
      else
    end
    return obj
  else
    error(@currentToken[0],"ERR_DUPLICATE_IDENT")
    return nil
  end
end

def addObject(objList, obj)
  return 0 if @stop 
  objList<<obj if objList.class==Array
end

def findObject(objList, name)
  return 0 if @stop  
  if objList
    objList.each do |obj|
      return obj if obj[:name]==name
    end
  end
  return {}
end

def lookupObject(name)
  return 0 if @stop    
  scope = @symtab[:currentScope]    
  while (scope != nil) do
    obj = findObject(scope[:objList], name)   
    return obj if obj!={} 
    scope = scope[:outer]
  end      
  return findObject(@symtab[:objList], name)
end

def initSymTab
  return 0 if @stop

  @symtab={program:{}, objList:[], currentScope:{}}

  @readc={name:"READC",kind:"OBJ_FUNCTION",type:makeCharType}
  @symtab[:objList]<<@readc
  @readi={name:"READI",kind:"OBJ_FUNCTION",type:makeIntType}
  @symtab[:objList]<<@readi

  @writei={name:"WRITEI",kind:"OBJ_PROCEDURE",paramList:[]}  
  @writei[:paramList]<< {name:"i",kind:"OBJ_PARAMETER",paramkind:"PARAM_VALUE",type:makeIntType,owner:@writei}
  @symtab[:objList]<< @writei

  @writec={name:"WRITEC",kind:"OBJ_PROCEDURE",paramList:[]}  
  @writec[:paramList]<< {name:"ch",kind:"OBJ_PARAMETER",paramkind:"PARAM_VALUE",type:makeCharType,owner:@writec}
  @symtab[:objList]<< @writec
  
  @writeln={name:"WRITELN",kind:"OBJ_PROCEDURE"}
  @symtab[:objList]<< @writeln   
end

def enterBlock(scope)
  @symtab[:currentScope]=scope
end

def exitBlock
  return 0 if @stop
  @symtab[:currentScope]=@symtab[:currentScope][:outer]
end

def sizeOfType(type)
  case type[:typeClass]
    when "TP_INT"
      return INT_SIZE
    when "TP_CHAR"
      return CHAR_SIZE
    when "TP_ARRAY"
      return (type[:arraySize] * sizeOfType(type[:elementType]))
  end
  return 0
end

def declareObject(obj)
  return 0 if @stop
  if @symtab[:currentScope]=={}
    addObject(@symtab[:objList],obj)
  else
    case obj[:kind]
      when "OBJ_FUNCTION","OBJ_PROCEDURE"
        obj[:scope][:outer] = @symtab[:currentScope]
      when "OBJ_VARIABLE"
        obj[:scope] = @symtab[:currentScope]
        obj[:localOffset] = @symtab[:currentScope][:frameSize]
        @symtab[:currentScope][:frameSize] += sizeOfType(obj[:type])      
      when "OBJ_PARAMETER"
        obj[:scope] = @symtab[:currentScope]
        obj[:localOffset] = @symtab[:currentScope][:frameSize]
        @symtab[:currentScope][:frameSize] +=1
        owner = @symtab[:currentScope][:owner]
        owner[:paramList]=[] unless owner[:paramList]
        owner[:paramList]<<obj
        owner[:paramCount] +=1                   
      else      
    end 
    addObject(@symtab[:currentScope][:objList], obj)
  end
end