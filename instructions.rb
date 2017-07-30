INT_SIZE=1
CHAR_SIZE=1
MAX_BLOCK=50

@opcode={
  :LA=>0,# Load Address:    t := t + 1; s[t] := base(p) + q;
  :LV=>1,# Load Value:      t := t + 1; s[t] := s[base(p) + q];
  :LC=>2,# load Constant    t := t + 1; s[t] := q;
  :LI=>3,# Load Indirect    s[t] := s[s[t]];
  :INT=>4,#  // Increment t      t := t + q;
  :DCT=>5,#  // Decrement t      t := t - q;
  :J=>6,#    // Jump             pc := q;
  :FJ=>7,# False Jump       if s[t] = 0 then pc := q; t :=t - 1;
  :HL=>8,# Halt             Halt
  :ST=>9,# Store            s[s[t-1]] := s[t]; t := t -2;
  :CALL=>10,# // Call             s[t+2] := b; s[t+3] := pc; s[t+4]:= base(p); b:=t+1; pc:=q;
  :EP=>11,# Exit Procedure   t := b - 1;  pc := s[b+2];  b := s[b+1];
  :EF=>12,# Exit Function    t := b;  pc := s[b+2];  b := s[b+1];
  :RC=>13,# Read Char        read one character into s[s[t]];  t := t - 1;
  :RI=>14,# Read Integer     read integer to s[s[t]];  t := t-1;
  :WRC=>15,#  // Write Char       write one character from s[t];  t := t-1;
  :WRI=>16,#  // Write Int        write integer from s[t];  t := t-1;
  :WLN=>17,#  // WriteLN          CR/LF
  :AD=>18,# Add              t := t-1;  s[t] := s[t] + s[t+1];
  :SB=>19,# Substract        t := t-1;  s[t] := s[t] - s[t+1];
  :ML=>20,# Multiple         t := t-1;  s[t] := s[t] * s[t+1];
  :DV=>21,# Divide           t := t-1;  s[t] := s[t] / s[t+1];
  :NEG=>22,# // Negative         s[t] := - s[t];
  :CV=>23,# Copy Top         s[t+1] := s[t]; t := t + 1;
  :EQ=>24,# Equal            t := t - 1;  if s[t] = s[t+1] then s[t] := 1 else s[t] := 0;
  :NE=>25,# Not Equal        t := t - 1;  if s[t] != s[t+1] then s[t] := 1 else s[t] := 0;
  :GT=>26,# Greater          t := t - 1;  if s[t] > s[t+1] then s[t] := 1 else s[t] := 0;
  :LT=>27,# Less             t := t - 1;  if s[t] < s[t+1] then s[t] := 1 else s[t] := 0;
  :GE=>28,# Greater or Equal t := t - 1;  if s[t] >= s[t+1] then s[t] := 1 else s[t] := 0;
  :LE=>29,# Less or Equal    t := t - 1;  if s[t] >= s[t+1] then s[t] := 1 else s[t] := 0;

  :BP=>30#    // Break point. Just for debugging
}
def createCodeBlock(maxSize)  
  return {code: [], codeSize: 0, maxSize: maxSize }
end

def printInstruction(inst)
  case inst[:op]
    when "LA","LV","CALL"
    @output_file.write "#{inst[:op]} #{inst[:p]},#{inst[:q]}"
   when "LC","INT","DCT","J","FJ"        
    @output_file.write "#{inst[:op]} #{inst[:q]}" 
    else
    @output_file.write inst[:op]
  end
  save inst
end

def save inst
  @out_file.write [@opcode[inst[:op].to_sym]].pack "I"
  @out_file.write [inst[:p]].pack "I"
  @out_file.write [inst[:q]].pack "I"
end

def printCodeBlock(codeBlock)
  i=0
  codeBlock.each do |pc|
    @output_file.write "#{i}: "
    printInstruction pc
    @output_file.write("\n")
    i+=1
  end
end

