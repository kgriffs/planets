class Stats < SceneNode
	def initialize(window, player_1, player_2)
		super(window, nil)
	
		@font = Gosu::Font.new(window, Gosu::default_font_name, 20)
		@player_1 = player_1
		@player_2 = player_2
		
		@panel = Panel.new(window, 0, 0, window.width-1, 30, 0x77eeeeee, 0x44000000)
	end

	def draw
		@panel.draw
		
		p1_tint = 0x22008800
		p2_tint = 0x22000088
		
		player = @parent.current_player
		if player == @player_1
			p1_tint |= 0xf0000000
		elsif player == @player_2
			p2_tint |= 0xf0000000
		end
		
		@font.draw("Power: #{@player_1.power}", 10, 5, ZOrder::UI, 1.0, 1.0, p1_tint)				
		@font.draw("Power: #{@player_2.power}", @window.width - 100, 5, ZOrder::UI, 1.0, 1.0, p2_tint)				
	end
end