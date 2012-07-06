require 'gosu'

class SceneNode
	attr_accessor :parent

	def initialize(window, image_path)
		@children = []
		@window = window
		@parent = nil
		
		if (image_path)
			@image = Gosu::Image.new(window, image_path, false)
		end
	end

	def add_child(child)
		@children << child
		child.parent = self
	end
	
	def remove_child(child)
		@children.delete(child)
	end
end
