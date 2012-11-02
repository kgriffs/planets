class Panel
	def initialize(window, left, top, right, bottom, color_1, color_2)
		@window = window
	
		@left = left
		@top = top
		@right = right
		@bottom = bottom
		@color_1 = color_1
		@color_2 = color_2
	end

	def draw
		@window.draw_quad(@left, @top, @color_1, @right, @top, @color_1, @left, @bottom, @color_2, @right, @bottom, @color_2, ZOrder::UI)		
	end
end