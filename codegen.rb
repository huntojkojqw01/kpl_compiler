RESERVED_WORDS=4
CODE_SIZE=10000

RETURN_VALUE_OFFSET=0
DYNAMIC_LINK_OFFSET=1
RETURN_ADDRESS_OFFSET=2
STATIC_LINK_OFFSET=3

def computeNestedLevel( scope)
  return 0 if @stop
  level = 0
  currentScope = @symtab[:currentScope]    
  
  while(scope != currentScope) do
    level+=1

    currentScope = currentScope[:outer]

  end
  return level  
end

def genAddress(obj)
  return 0 if @stop
    gen("LA",obj[:localOffset], computeNestedLevel(obj[:scope]))  
end

def genValue(obj)
  return 0 if @stop 
    gen("LV",obj[:localOffset], computeNestedLevel(obj[:scope]))  
end

def genRA(func)
  return 0 if @stop  
  gen("LA",0, computeNestedLevel(func[:scope]))
end

def genRV(func)
  return 0 if @stop  
  gen("LV",0, computeNestedLevel(func[:scope]))  
end

def genCall(obj)
  return 0 if @stop  
  gen("CALL",obj[:codeAddress], computeNestedLevel(obj[:scope][:outer]))
end

def isPredefined( obj)
  return [@readi,@readc,@writei,@writec,@writeln].include? obj
end

def genPredefined(obj)
  return 0 if @stop
  if (obj == @writei)
    gen "WRI"
  elsif (obj == @writec)
    gen "WRC"
  elsif (obj == @writeln)
    gen "WLN"
  elsif (obj == @readi)
    gen "RI"
  elsif (obj == @readc)
    gen "RC"  
	end
end

def gen(code,q=0,p=0)  
  return 0 if (@codeBlock[:codeSize] >= @codeBlock[:maxSize])||@stop
  inst= {op: code,p: p,q: q}
  @codeBlock[:code]<< inst
  @codeBlock[:codeSize]+=1
  return inst
end

def updateJ(jmp, label)
  jmp[:q] = label
end

def getCurrentCodeAddress
  return @codeBlock[:codeSize]
end

def initCodeBuffer
  return 0 if @stop
  @codeBlock = createCodeBlock(CODE_SIZE)
end

def printCodeBuffer
  return 0 if @stop
  printCodeBlock(@codeBlock)
end