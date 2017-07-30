PS_ACTIVE=         0
PS_INACTIVE =      1
PS_NORMAL_EXIT =   2
PS_DIVIDE_BY_ZERO =4
STACK_SIZE=10000
@opcode={
  :LA=>0,# Load Address:    t := t + 1 s[@t] := base(p) + q
  :LV=>1,# Load Value:      t := t + 1 s[@t] := s[base(p) + q]
  :LC=>2,# load Constant    t := t + 1 s[@t] := q
  :LI=>3,# Load Indirect    s[@t] := s[s[@t]]
  :INT=>4,#  # Increment t      t := t + q
  :DCT=>5,#  # Decrement t      t := t - q
  :J=>6,#    # Jump             pc := q
  :FJ=>7,# 0 Jump       if s[@t] = 0 then pc := q t :=t - 1
  :HL=>8,# Halt             Halt
  :ST=>9,# Store            s[s[t-1]] := s[@t] t := t -2
  :CALL=>10,# # Call             s[t+2] := b s[t+3] := pc s[t+4]:= base(p) b:=t+1 pc:=q
  :EP=>11,# Exit Procedure   t := b - 1  pc := s[b+2]  b := s[b+1]
  :EF=>12,# Exit Function    t := b  pc := s[b+2]  b := s[b+1]
  :RC=>13,# Read Char        read one character into s[s[@t]]  t := t - 1
  :RI=>14,# Read Integer     read integer to s[s[@t]]  t := t-1
  :WRC=>15,#  # Write Char       write one character from s[@t]  t := t-1
  :WRI=>16,#  # Write Int        write integer from s[@t]  t := t-1
  :WLN=>17,#  # WriteLN          CR/LF
  :AD=>18,# Add              t := t-1  s[@t] := s[@t] + s[@t+1]
  :SB=>19,# Substract        t := t-1  s[@t] := s[@t] - s[@t+1]
  :ML=>20,# Multiple         t := t-1  s[@t] := s[@t] * s[@t+1]
  :DV=>21,# Divide           t := t-1  s[@t] := s[@t] / s[@t+1]
  :NEG=>22,# # Negative         s[@t] := - s[@t]
  :CV=>23,# Copy Top         s[@t+1] := s[@t] t := t + 1
  :EQ=>24,# Equal            t := t - 1  if s[@t] = s[@t+1] then s[@t] := 1 else s[@t] := 0
  :NE=>25,# Not Equal        t := t - 1  if s[@t] != s[@t+1] then s[@t] := 1 else s[@t] := 0
  :GT=>26,# Greater          t := t - 1  if s[@t] > s[@t+1] then s[@t] := 1 else s[@t] := 0
  :LT=>27,# Less             t := t - 1  if s[@t] < s[@t+1] then s[@t] := 1 else s[@t] := 0
  :GE=>28,# Greater or Equal t := t - 1  if s[@t] >= s[@t+1] then s[@t] := 1 else s[@t] := 0
  :LE=>29,# Less or Equal    t := t - 1  if s[@t] >= s[@t+1] then s[@t] := 1 else s[@t] := 0
  :BP=>30#    # Break point. Just for debugging
}

def resetVM
  @pc = 0
  @t = -1
  @b = 0
  @ps = PS_INACTIVE
end

def initVM
  @codes = []
  @stack=[]
  0.upto(STACK_SIZE) do |i|
    @stack[i]=0
  end
  resetVM
end

def loadExecutable(filename)  
  begin    	
	  	f=File.new(filename,"r")
	  	i=0
	  	while str = f.read(12) 
	      	array= str.unpack "III"	      	
	      	@codes<<{op:array[0], p:array[1], q:array[2]}	      	
	  	  	i+=1
	    end
	    f.close  
	  	rescue Exception => msg     
	    	puts msg  
	end
  resetVM  
end

def base(p)
  currentBase = @b
  while (p > 0)
    currentBase = @stack[currentBase + 3]
    p-=1
  end
  return currentBase
end

def printMemory 
  print "Start dumping...\n"
  0.upto(@t) do |i|
    print "#{i}: #{@stack[i] ? @stack[i] : 0 }\n"
  end
  print "Finish dumping!\n"
end

def printInstruction(inst)  
  opcode = @opcode.key(inst[:op]).to_s      
      	case opcode
  	    	when "LA","LV","CALL"
  		    	print "#{opcode} #{inst[:p]},#{inst[:q]}\n"
  		   	when "LC","INT","DCT","J","FJ"    
  		    	print "#{opcode} #{inst[:q]}\n" 
  		    else
  	    		print "#{opcode}\n" 
  	  	end
end

def printCodeBuffer
  i=0
  @codes.each do |inst|
    print "#{i}: "
    printInstruction inst    
    i+=1
  end
end

def run  
  @ps = PS_ACTIVE
  while (@ps == PS_ACTIVE)    
  	code=@codes[@pc]       
    break if code==nil
  	p=code[:p]
  	q=code[:q]
    printInstruction code if @debug
    case @opcode.key(code[:op]).to_s
      when "LA" 
        @t +=1
        @stack[@t] = base(p) + q
      when "LV" 
        @t +=1
        @stack[@t] = @stack[base(p) + q]
      when "LC"
        @t +=1
        @stack[@t] = q
      when "LI" 
        @stack[@t] = @stack[@stack[@t]]
      when "INT"
        @t += q
      when "DCT"
        @t -= q
      when "J" 
        @pc = q - 1
      when "FJ"      
  		  @pc = q - 1 if (@stack[@t] == 0) 
        @t -=1    
      when "HL"
        @ps = PS_NORMAL_EXIT
      when "ST"
        #@debug=true 
        @stack[@stack[@t-1]] = @stack[@t]
        @t -= 2
      when "CALL"
        @stack[@t+2] = @b                 # Dynamic Link
        @stack[@t+3] = @pc                # Return Address
        @stack[@t+4] = base(p)            # Static Link
        @b = @t + 1                      # Base & Result
        @pc = q - 1     
      when "EP" 
        @t = @b - 1                      # Previous top
        @pc = @stack[@b+2]                # Saved return address
        @b = @stack[@b+1]                 # Saved base      
      when "EF"
        @t = @b                          # return value on top
        @pc = @stack[@b+2]                # saved return address
        @b = @stack[@b+1]                 # saved base
      when "RC" 
        @t +=1        
        @stack[@t] = STDIN.gets.ord
      when "RI"
        #@debug=true
        @t +=1        
        @stack[@t] = STDIN.gets.chomp.to_i        
      when "WRC"
        print "#{@stack[@t].chr}\n"
        @t-=1
      when "WRI" 
        print "#{@stack[@t]}\n"
        @t-=1      
      when "WLN"
        print("\n")      
      when "AD"
        @t-=1
        @stack[@t] += @stack[@t+1]      
      when "SB"
        @t-=1
        @stack[@t] -= @stack[@t+1]      
      when "ML"
        @t-=1
        @stack[@t] *= @stack[@t+1]
      when "DV"
        @t-=1
        if(@stack[@t+1] == 0)
          @ps = PS_DIVIDE_BY_ZERO
          p "Unable divide by 0."
        else
          @stack[@t] /= @stack[@t+1]
        end      
      when "NEG"
        @stack[@t] = - @stack[@t]      
      when "CV" 
        @stack[@t+1] = @stack[@t]
        @t +=1      
      when "EQ"
        @t-=1
        @stack[@t]= (@stack[@t] == @stack[@t+1]) ? 1 : 0
      when "NE"
        @t-=1
        @stack[@t]= (@stack[@t] != @stack[@t+1]) ? 1 : 0
      when "GT"
        @t-=1
        @stack[@t]= (@stack[@t] > @stack[@t+1]) ? 1 : 0
      when "LT"
        @t-=1
        @stack[@t]= (@stack[@t] < @stack[@t+1]) ? 1 : 0
      when "GE"
        @t-=1
        @stack[@t]= (@stack[@t] >= @stack[@t+1]) ? 1 : 0      
      when "LE"
        @t-=1
        @stack[@t]= (@stack[@t] <= @stack[@t+1]) ? 1 : 0
      #when "BP"
            #debugMode = 1      
      else 
    end#case @opcode.key(code[:op]).to_s
    
    if @debug            
      begin
          tmp=STDIN.gets.chomp                  
        	command = tmp if tmp != "\n"
        	case(command)
          	when 'A','a'
          	  print "\nEnter memory location (level, offset):"
          	  tmp=STDIN.gets.chomp.split(',')
          	  print "Absolute address = #{base(tmp[0].to_i) + tmp[1].to_i}\n"
          	  debugging = true
          	when 'M','m'
          	  print "\nEnter memory location (level, offset):"
          	  tmp=STDIN.gets.chomp.split(',')
              val=@stack[base(tmp[0].to_i) + tmp[1].to_i]          	  
              print "Value = #{ val ? val : 0}\n"
          	  debugging = true
          	when 'T','t'                      	  
              print "Top (#{@t}) = #{@stack[@t] ? @stack[@t] : 0 }\n"              
          	  debugging = true       	
          	when 'C','c'
              #@debug=false
          	  debugging = false       	
          	when 'H','h'
          	  @ps = PS_NORMAL_EXIT
              debugging = false
            when 'n'
              @debug=false  
              debugging = false
            when 'p'
              printMemory 
              debugging = true         
          	else
              print "Command:\n t(top), a(address), m(mem), c(next step), h(halt),\n e(exit debug, normal run), p(printMem).\n"
              debugging = true 
          end#case(command)
      end while debugging
    end# if @debug
    @pc +=1
  end# of while ps==PS_ACTIVE  
end# run
initVM
loadExecutable ARGV[0] if ARGV[0]
case ARGV[1]
  when "-debug"
    @debug=true
    run
  when "-dump"
    printCodeBuffer  
  else
    @debug=false
    run
  end    



          
