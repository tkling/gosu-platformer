# frozen_string_literal: true

require 'gosu'
require 'singleton'

module ZOrder
  BACKGROUND, LEVEL, PICKUPS, CHARACTER, UI_BACKDROP, UI = *0..5
end

class GameWindow < Gosu::Window
  include Singleton

  attr_reader :game_state, :root_dir, :level, :advance_duration, :ui

  def self.root_dir = instance.root_dir
  def self.level = instance.level
  def self.advance_duration = instance.advance_duration
  def self.game_state = instance.game_state

  def initialize
    super 1280, 720, fullscreen: false
    self.caption = 'Gosu Platformer'

    @game_state = GameState.new
    @root_dir = File.dirname(File.expand_path(__FILE__), 2)
    @level = Level1.new
    @ui = UI.new

    @advance_distance = 422 # Pixels between each stage (72px * 6 blocks).
    advance_speed = 4.0 # Pixels per frame.
    @advance_duration = (@advance_distance / advance_speed) / 60 # Kinematics v=d/t. Scaled by framerate.

    # Music!
    @music = Gosu::Song.new('sounds/music.mp3')
    @music.play(looping=true)
  end

  def character
    # Starting at x:252 means we can consistently advance to the exact center of each stage.
    # The floor is at y:648, but we subtract 128px for the character sprite.
    @character ||= Character.new(252, 520)
  end

  def update
    handle_input
    level.update if game_state.advancing
    character.update_locomotion
  end

  def handle_input
    close if Gosu.button_down?(Gosu::KB_ESCAPE)

    # Handle tutorial click.
    if !game_state.tutorial_done && Gosu.button_down?(Gosu::MS_LEFT)
      game_state.tutorial_done = true
      game_state.input_locked = false
    end

    return if game_state.input_locked

    if Gosu.button_down?(Gosu::MS_LEFT)
      card = ui.action_for_coordinates(self.mouse_x, self.mouse_y)
      return unless card # Nothing clicked.

      game_state.input_locked = true
      character.perform(card)
      level.advance_stage! unless card == RestCard
    end
  end

  # Triggered by player input.
  def skip_stage
    Thread.new do
      sleep 1
      game_state.input_locked = false
    end

    game_state.input_locked = true
  end

  def draw
    level.draw
    character.draw
    ui.draw game_state
  end
end
