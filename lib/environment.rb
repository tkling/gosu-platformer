# frozen_string_literal: true

require 'gosu'

module Environment
  def self.initialize
    @sprite = Gosu::Image.new('sprites/levels/level1.png', tileable: false)
    @scale = 0.5625 # 1280px to 720px. TODO: Make this dynamic.
    @speed = 4.0
    @pos_x = 0
  end

  def self.move_left
    @pos_x -= @speed
  end

  def self.move_right
    @pos_x += @speed
  end

  def self.draw
    @sprite.draw(@pos_x, 0, ZOrder::ENVIRONMENT, @scale, @scale)
  end
end