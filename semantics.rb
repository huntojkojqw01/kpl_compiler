def eat_declared_ident
    return 0 if @stop
    eat "TK_IDENT" 
    obj = lookupObject(@currentToken[2])
    if obj=={}
        error(@currentToken[0],"ERR_UNDECLARED_IDENT")
        return {}
    else
        return obj
    end   
end

def eat_declared_ident_type(type)
    return 0 if @stop   
    obj = eat_declared_ident
    error(@currentToken[0],"ERR_INVALID_#{type}") unless obj[:kind]=="OBJ_#{type}"
    return obj   
end

def checkType(type, unit)
    return 0 if @stop
    case unit
    when "INT","CHAR","ARRAY"
        return true if type && type[:typeClass]=="TP_#{unit}"
    when "BASIC"
        return true if type && ( type[:typeClass]=="TP_INT"||type[:typeClass]=="TP_CHAR" )
    else        
    end
    error(@currentToken[0],"ERR_#{unit}_INCONSISTENCY")  
end

def checkTypeEquality(type1, type2, unit="TYPE")
    return 0 if @stop          
    error(@currentToken[0],"ERR_#{unit}_INCONSISTENCY")  unless type1==type2  
end