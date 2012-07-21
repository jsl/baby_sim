require 'baby_sim/baby'
require 'baby_sim/cell'
require 'baby_sim/field'
require 'baby_sim/thing'
require 'baby_sim/version'



module BabySim

  COLORS = {
    red: '#FF0000',
    yellow: '#FFFF00',
    purple: '##FF00FF',
    green: '#00FF00'
  }

  Thing.new('Samurai Sword') do
    color COLORS[:red]
    effect -2
    count 20
    message "Ouch! That's sharp!"
  end

  Thing.new('Banana') do
    color COLORS[:yellow]
    effect +2
    count 30
    message "Yum! Tasty banana."
  end
end

require 'baby_sim/shoes'


