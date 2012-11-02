class SpaceStage < Stage
	attr_reader :current_player, :player_firing, :winner

	def planet_collides?(planet)
		@planets.each do |each_other|
			return true if planet.collides_with? each_other
		end
		
		@players.each do |each_other|
			return true if planet.collides_with? each_other
		end
		
		false
	end
	
	def player_collides?(player)	
		@players.each do |each_other|
			return true if player.collides_with? each_other
		end
		
		false
	end

	def make_planets(count)
		@planets = []

		while @planets.length < count
			planet = nil
			while planet.nil?				
				planet = PlanetActor.new(@window)				
				planet = nil if planet_collides?(planet)
			end
			
			@planets << planet
		end

		@planets.each { |each_planet|	add_child each_planet }
	end
	
	def make_black_holes(count)
		@black_holes = []

		while @black_holes.length < count
			black_hole = nil
			while black_hole.nil?				
				black_hole = BlackHoleActor.new(@window)				
				black_hole = nil if planet_collides?(black_hole)
			end
			
			@black_holes << black_hole
		end

		@black_holes.each { |black_hole|	add_child black_hole }
	end

	def make_players(count)
		@players = []
		padding = 100
		count = 2

		while @players.length < count
			player = nil
			while player.nil?				
				x = padding + rand(padding)
				angle = 90
				
				if (@players.length == 1)
					x = (@window.width - padding) - rand(padding)
					angle = 270
				end
					
			
				player = RocketActor.new(
					@window, 
					#rand(@window.width - padding) + padding / 2, 
					x,
					rand(@window.height - padding) + padding / 2, 
					angle, 
					@players.length + 1
				)				
				player = nil if player_collides?(player)
			end
			
			@players << player
		end

		@players.each { |each_player| add_child each_player }
	end
	
	def initialize(window)
		super(window, 'media/background.png')		
		srand
		
		@close_call_filenames = Dir.glob("./media/close_call_*.ogg")		

		hit_planet_filename = 
			if File.exists? "./media/smash.ogg"
				"./media/smash.ogg"
			else
				"./media/smash.wav"
			end
			
		@hit_planet_sound = Gosu::Sample.new(window, hit_planet_filename)
		@fire_sound = Gosu::Sample.new(window, 'media/fire.ogg');
		
		hit_player_filename = 
			if File.exists? "./media/explosion.ogg"
				"./media/explosion.ogg"
			else
				"./media/explosion.wav"
			end

		@hit_player_sound = Gosu::Sample.new(window, hit_player_filename)		
	
		make_players(2)

		# Assumes players are already created
		make_planets(5)
		
		make_black_holes(1)

		@stats = Stats.new(window, @players[0], @players[1])
		add_child @stats
		
		@player_turn = 0
		
		@current_player = @players[@player_turn]
		@player_firing = false
		@winner = nil
	end

	def next_turn
		@hit_planet_sound.play(1.2)
	
		@player_turn += 1
		@player_turn %= @players.length

		@current_player = @players[@player_turn]
		@player_firing = false

		@first_close_call = false
	end
	
	def before_frame
		return if @player_hit
	
		if @player_firing
			@planets.each do |each_planet|
				if @torpedo.collides_with? each_planet
					remove_child @torpedo
					next_turn
					return
				end
			end
			
			@players.each do |each_player|
				if (@torpedo.collides_with? each_player)
					@player_hit = true

					remove_child @torpedo
					@hit_player_sound.play(0.8)
					each_player.hit
					return
				elsif (@torpedo.close_call? && each_player != @current_player && !@first_close_call)
					@first_close_call = true
					@close_call_sound = Gosu::Sample.new(@window, @close_call_filenames[rand(@close_call_filenames.length)])
					@close_call_sound.play(0.9)
				end
			end
		
			extra_width = @window.width * 1
			extra_height = @window.height * 1
		
			if @torpedo.x_position < (extra_width * -1) || @torpedo.x_position > (@window.width + extra_width)
				remove_child @torpedo
				next_turn
				return
			end
			
			if @torpedo.y_position < (extra_height * -1) || @torpedo.y_position > (@window.height + extra_height)
				remove_child @torpedo
				next_turn
				return
			end
		else
	    if @window.button_down? Gosu::Button::KbLeft
	      @current_player.rotate_left
			elsif @window.button_down? Gosu::Button::KbRight
	      @current_player.rotate_right
			end
		end
	end

	
	def button_down(id)
		if id == Gosu::Button::KbLeftControl
			@window.restart		
		elsif id == Gosu::Button::KbLeftAlt
			@window.toggle_music
		end
		
		return if @player_firing || @player_hit
	
		if id == Gosu::Button::KbUp
			@current_player.increase_power
		elsif id == Gosu::Button::KbDown
			@current_player.decrease_power
		elsif id == Gosu::Button::KbSpace
			@player_firing = true
			@torpedo = @current_player.torpedo(@planets + @black_holes)
			add_child @torpedo
			@fire_sound.play(0.4)			
		#elsif id == Gosu::Button::KbSpace
		#	@player_hit = true
		#	@hit_player_sound.play
		#	@current_player.hit		
		end
	end
end