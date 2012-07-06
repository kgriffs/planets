require 'gosu'
require 'stage'

class Actor < SceneNode
	def squared_distance_from(x, y)
		x_distance = @x_position - x
		y_distance = @y_position - y
		
		(x_distance * x_distance + y_distance * y_distance)		
	end

	def close_call?
		@close_call
	end
	
	def collides_with?(other)
		distance = Math.sqrt(squared_distance_from(other.x_position, other.y_position))
		allowance = (@diameter + other.diameter) / 2
		
		@close_call = distance < (allowance * 4)
		
		distance <= allowance
	end	
	
	def warp(x, y)
		@x_position = x
		@y_position = y
	end
	
	def move_next
    @x_position += @x_velocity
    @y_position += @y_velocity
		
    #@x_position %= @window.width
    #@y_position %= @window.height		
		
	end
	
	def rotate_left
		@angle -= @rotation_step
		
		if (@angle < 0)
			@angle += 360
		end
	end
		
	def rotate_right
		@angle += @rotation_step		
		@angle %= 360
	end
	
	def draw
		move_next
		
		@image.draw_rot(@x_position, @y_position, @z_order, @angle, 0.5, 0.5, @scale_x, @scale_y, @tint)		
		@children.each do |each_child| 
			each_child.draw 
		end
	end

	attr_reader :tint, :x_position, :y_position, :diameter
	
	def initialize(window, image_path, options={})	
		super(window, image_path)
		
		@close_call = false
		
		if options.has_key? :tint
			@tint = options[:tint]			
		else
			@tint = 0xffffffff
		end

		if options.has_key? :scale
			@scale_x = options[:scale]			
			@scale_y = options[:scale]			
		else
			@scale_x = 1.0
			@scale_y = 1.0
		end

		@width = @image.width * @scale_x
		@height = @image.height * @scale_y
		@diameter = [@width, @height].max

		if options.has_key? :z_order
			@z_order = options[:z_order]			
		else
			@z_order = 0
		end

		if options.has_key? :x_position
			@x_position = options[:x_position]			
		else
			@x_position = window.width / 2
		end

		if options.has_key? :y_position
			@y_position = options[:y_position]			
		else
			@y_position = window.height / 2
		end

		if options.has_key? :x_velocity
			@x_velocity = options[:x_velocity]			
		else
			@x_velocity = 0
		end

		if options.has_key? :y_velocity
			@y_velocity = options[:y_velocity]			
		else
			@y_velocity = 0
		end

		if options.has_key? :angle
			@angle = options[:angle]			
		else
			@angle = 0
		end
		
		if options.has_key? :rotation_step
			@rotation_step = rotation_step			
		else
			@rotation_step = 1
		end
	end
end