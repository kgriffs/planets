Planets! 1.2

License and Customizing:

Planets! is copyright (c) 2006-2012 by Kurt Griffiths, all rights reserved. You may redistribute under the terms of the GNU General Public License (see gpl.txt). Any changes or use you make are fine by me, as long when you redistribute the program, you send me a copy and note me as the original author in the new version.

Disclaimer:

This was written a while ago in my spare time and was my first experience programming a game using Ruby. The code may not be pretty, but it seems to work well enough. Feel free to send me suggestions and bug reports. 

Known to work on Mac OS X. Should work on other operating systems as long as you have Ruby 1.9 and the Gosu gem installed.

Controls:

-- Left and right arrow keys turn your ship. 
-- Up and down change the power (velocity) you give your torpedos. 
-- Space bar shoots
-- Left alt toggles the music
-- Left ctrl gives you a new board (in case the one you are on is impossible)
-- Press 'q' or ESC to quit

Troubleshooting:

-- You may need to grab MSVCP71.DLL and put it in the same folder as planets if Windows gives you an error about it.
-- Latest version only tested on Mac OS X. May require some TLC on other systems.

Customizing:

-- If you want background music in the source distro just add "background_music.ogg" file in the "media" directory. You can also replace any of the sound effect or image files there if you want to customize the game.
-- For more/different planets, add your own files. Planets! chooses randomly from anything named "./media/planet-*.png"
-- For more/different close-call sound effects, add your own OGGs. Planets! chooses randomly from anything named "./media/close_call_*.ogg"

Kudos go to:

-- Matz and co. for the Ruby programming language
-- Gosu game library and team
-- The fine people behind FMOD
-- My wife for her patience and understanding

Enjoy!

@kgriffs