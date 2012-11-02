#!/usr/bin/env ruby

module ZOrder
  Background, Player, UI = *0..2
end

$LOAD_PATH << "."

# Need gosu, actor, and supporting_actors since the rest of the classes depend on them
require 'gosu'
require 'actor'
require 'supporting_actors'

require 'panel'
require 'stats'
require 'space_stage'
  
class GameWindow < Gosu::Window
	attr_accessor :game_state

	def toggle_music
		return unless @background_music
	
		@music_on = !@music_on
		if @music_on
			@background_music.play
		else
			@background_music.stop
		end
	end
	
  def initialize	
    super(1200, 675, false)
    self.caption = "Planets!"

		@stage = SpaceStage.new(self)
		
		@music_on = true
		
		if File.exists? 'media/background_music.ogg'
			@background_music = Gosu::Song.new(self, 'media/background_music.ogg', :stream)
		else
			@background_music	= nil
		end
		
		@shutting_down = false
  end
	
  def button_down(id)
		return if @shutting_down

    if id == Gosu::Button::KbEscape || id == Gosu::Button::KbQ
			@shutting_down = true
			@background_music.stop if @background_music
			@background_music = nil
					
      close
    end
		
		@stage.button_down(id)
  end
  
  def draw
		return if @shutting_down

		@stage.draw
  end

  def update
		return if @shutting_down
	
		@stage.before_frame
		
		if @background_music and !@background_music.playing? and @music_on
			@background_music.play
		end
  end
	
	def restart
		return if @shutting_down

		@stage = SpaceStage.new(self)		
	end
end

GameWindow.new.show
