def error(position,err)
  @output_file.write "#{position[0]}-#{position[1]}:ERROR!(#{Errors[err.to_sym]})\n"
  @stop=true 
end
def missToken(position,need,meet)
  @output_file.write "#{position[0]}-#{position[1]}:ERROR!(Need token #{need} but meet token #{meet})\n"
  @stop=true
end







