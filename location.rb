
class Location
	attr_accessor :full, :floor, :x, :y
	
	def initialize(code)
		@full = code
		@floor, @x, @y = code[1].to_i,code[2],code[3].to_i
	end
	
	def distance_to(location)
		vert = (@floor - location.floor.to_i).abs
		horiz = ((@y - location.y).abs + (@x.ord - location.x.ord).abs)
		vert + horiz			
	end
	
		
end
