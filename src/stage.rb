require 'gosu'
require 'scene_node'

class Stage < SceneNode
	def initialize(window, image_path)
		super(window, image_path)
		@background_x = 0
	end
	
	def draw
		@image.draw(@background_x, 0, 0, 1.2, 1.2)
#
#		@image.draw(@window.width + @background_x, 0)
		
#		@background_x -= 2
#		if (-1 * @background_x) > @window.width
#			@background_x = 0
#		end
		
		@children.each { |each_child| each_child.draw }
	end
end