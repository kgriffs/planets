require 'gosu'
require 'actor'

class TorpedoLine < SceneNode
	def initialize(window, x_position, y_position, tint)
		@points = [[x_position, y_position]]
		@tint = tint - 0x22222222
		
		@fudge = 50
	
		super(window, nil)
	end
	
	def add_point(x, y)
		@points << [x, y]
	end
	
	def draw
		num_points = @points.length
		return if num_points < 2
		
		previous_point = @points[0]

		index = 1
		while index < num_points
			this_point = @points[index]
			
			#if this_point[0] > (-1 * @fudge) && this_point[1] > (-1 * @fudge) && this_point[0] < (@window.width + @fudge) && this_point[1] < (@window.height + @fudge)
				@window.draw_line(previous_point[0], previous_point[1], @tint, this_point[0], this_point[1], @tint, ZOrder::Background)
			#end
		
			previous_point = this_point
			
			# If we draw all of them, it is too slow when we have tons of trails
			index += 2
		end
	end
end

class Torpedo < Actor
	def initialize(window, rocket, torpedo_line, planets, angle, power, tint)
		x_velocity = Gosu::offset_x(angle, power)
		y_velocity = Gosu::offset_y(angle, power)
		
		@planets = planets
	
		super(
			window, 
			'media/torpedo.png', 
			:x_velocity => x_velocity,			
			:y_velocity => y_velocity,			
			:z_order => ZOrder::Player, 
			:tint => tint
		)
		
		distanceFromRocketCenter = (rocket.diameter / 2) + @diameter

		x = rocket.x_position + Gosu::offset_x(angle, distanceFromRocketCenter)
		y =	rocket.y_position + Gosu::offset_y(angle, distanceFromRocketCenter)
		
		warp(x, y)

		@torpedo_line = TorpedoLine.new(window, x, y, tint)
		rocket.add_child @torpedo_line
	end
		
	def move_next
		@angle += 0.1		
		@angle = 0.0 if @angle > 359.0
	
		@planets.each do |each_planet|
			gravity = each_planet.gravity_from(@x_position, @y_position)
			angle_to_planet = each_planet.angle_from(@x_position, @y_position)
			
			@x_velocity += Gosu::offset_x(angle_to_planet, gravity)
			@y_velocity += Gosu::offset_y(angle_to_planet, gravity)
			
			#if @x_position < 0 || @x_position > @window.width || @y_position < 0 || @y_position > @window.height
			#	color1 = 0x04000000
			#	color2 = 0x33000000
			#	@window.draw_line(@x_position, @y_position, color1, each_planet.x_position, each_planet.y_position, color2) 
			#end
		end
	
		super
		
		@torpedo_line.add_point(@x_position, @y_position)
	end
end

class PlanetActor < Actor
	def initialize(window)
		# Get all images, ensuring the space station is at index 0
		planet_image_filenames = Dir.glob("./media/planet-*.png")
		planet_image_filenames.insert(0, "./media/space_station.png")
		
		# Choose a random image for the planet
		planet_number = rand(planet_image_filenames.length)
		filename = planet_image_filenames[planet_number]
	
		@is_space_station = planet_number.zero?
		
		if @is_space_station
			# Start them rotating in different positions to make them more interesting
			angle = rand(360)			
			scale = rand() + 0.3;	scale = 1.0	if scale > 1.0
			@gravity_factor = 12.0
		else
			# Give the planet a random tilt to make things interesting
			angle = -20 + rand(40) 
			scale =	rand() + 0.2
			@gravity_factor = 16.0
		end	
				
		super(
			window, 
			filename, 
			:x_position => rand(window.width),
			:y_position => rand(window.height),
			:scale => scale,
			:z_order => ZOrder::Player,
			:angle => angle
		)
		
		# Do this after we call super, so we know @diameter
		if @is_space_station
			@rotation_step = 50.0 / @diameter;
		else
			@rotation_step = 0
		end
	end
	
	def move_next
		super
		
		@angle += @rotation_step
		@angle = 0 if @angle > 359.0
	end
	
	def angle_from(x, y)
		Gosu::angle(x, y, @x_position, @y_position)
	end
	
	def gravity_from(x, y)			
		(@width * @gravity_factor) / squared_distance_from(x, y)
	end
end

class BlackHoleActor < Actor
	def initialize(window)
		tint = 0x07FFFFFF
		filename = "media/black_hole.png"
		
		super(
			window, 
			filename, 
			:x_position => rand(window.width),
			:y_position => rand(window.height),
			:z_order => ZOrder::Player,
			:tint => tint
		)

		@gravity_factor =	64.0
	end
	
	def angle_from(x, y)
		Gosu::angle(x, y, @x_position, @y_position)
	end
	
	def gravity_from(x, y)			
		sd = squared_distance_from(x, y)
		(@width * @gravity_factor) / (sd * 2)
	end
end

class RocketActor < Actor
	attr_reader :power

	def initialize(window, x_position, y_position, angle, player_id)
		tint = 
			case player_id
			when 1
				0xffc4d7c5
			else
				0xFFc4c7d7
			end
			
		#@hit_frames = Gosu::Image.load_tiles(window, 'media/hit.png', 266, 190, false)
    @hit_image = Gosu::Image.new(window, 'media/hit.png', false)			
		@hit_frame_count = 30
		
		super(
			window, 
			'media/rocket.png', 
			:x_position => x_position, 
			:y_position => y_position, 
			:angle => angle, 
			:z_order => ZOrder::Player, 
			:tint => tint
		)
		@id = player_id
		
		@power = 10.0
		@power_step = 0.5
		@power_range = (1.0..15.0)
		
		@hit = false
		@hit_time = 0.0
	end
	
	def hit
		@hit = true
		@hit_index = 0		
		@hit_tint = 0xffffffff
		@hit_tint_step = (255.0 / @hit_frame_count).to_i * 0x01000000
	end
	
	def draw
		if @hit
			@tint = 0x00000000
			@hit_index += 1
			if @hit_index > 120
				@window.restart
			elsif @hit_index < @hit_frame_count	
				# Don't do the last one, so it fades out completely
				
				# image = @hit_frames[@hit_index]
				scale = 0.2 + @hit_index / 4.0 * @hit_index / 4.0
				@hit_image.draw_rot(@x_position, @y_position, 10, 0, 0.5, 0.5, scale, scale, @hit_tint)
				@hit_tint -= @hit_tint_step
			end
		end

		super
	end
	
	def increase_power
		@power += @power_step
		if @power > @power_range.end
			@power = @power_range.begin
		end
	end
	
	def decrease_power
		@power -= @power_step
		if @power < @power_range.begin
			@power = @power_range.end
		end
	end
	
	def torpedo(planets)
		Torpedo.new(
			@window,
			self,
			@torpedo_line,
			planets,
			@angle,
			@power / 1.5,
			@tint
		)
	end
	
end
