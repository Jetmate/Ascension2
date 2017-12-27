Vector = require 'classes/Vector'
TileSheet = require 'classes/TileSheet'
Color = require 'classes/Color'
Player = require 'classes/Player'
SingleSpriteManager = require 'classes/SingleSpriteManager'
LevelManager = require 'classes/LevelManager'
GameManager = require 'classes/GameManager'

tprint = require 'tprint'

function draw(f)
  local function draw(...)
    love.graphics.setColor(0, 0, 0)
    f(...)
    love.graphics.setColor(255, 255, 255)
  end
  return draw
end

rectangle = draw(
  function (coords, size)
    love.graphics.rectangle('fill', coords[0], coords[1], size[0], size[1])
  end
)

function love.load(arg)
  io.stdout:setvbuf("no")

  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.graphics.setBackgroundColor(152, 152, 152)

  local SCALES = {1, 2, 3, 5, 10, 20}
  local GRAVITY = 270
  local COLOR_AMOUNT = 5
  local BLOCK_SIZE = 7
  local BLOCK_VECTOR = Vector(BLOCK_SIZE, BLOCK_SIZE)
  local DISPLAY_SIZE = Vector(1001, 1001)
  local LEVEL_SIZE = Vector(100, 100)
  local SCALE_INDEX = 3

  game_manager = GameManager(
    SCALES,
    SCALE_INDEX,
    DISPLAY_SIZE,
    LEVEL_SIZE,
    2
  )

  do
    local sheet_image = love.graphics.newImage('resources/tile_sheet.png')
    local sheet = TileSheet(sheet_image, BLOCK_SIZE)
    local sprites = {
      block = sheet:get_tile(),
      background = sheet:get_tile(),
      entrance = sheet:get_equal_sprites(Vector(17, 18), 10),
      spike = sheet:get_tile()
    }
    sprites.exit = tools.reverse(sprites.entrance)

    local sprite_speeds = {
      entrance = .15
    }
    sprite_speeds.exit = sprite_speeds.entrance
    local default_sprite_speed = .5

    local function convert_to_color(number, color_amount)
      base = color_amount + 1
      a = math.floor(number / base ^ 2)
      number = number - a * base ^ 2
      b = math.floor(number / base)
      number = number - b * base
      factor = 255 / color_amount
      return Color(number * factor, b * factor, a * factor)
    end

    local function generate_color_values(names, color_amount)
      t = {}
      for i, name in ipairs(names) do
        t[tostring(convert_to_color(i - 1, color_amount))] = name
      end
      return t
    end

    local names = {'block', 'entrance', 'exit', 'spike'}
    local color_values = generate_color_values(names, COLOR_AMOUNT)

    local direction_names = {math.pi * 3 / 2, math.pi / 2, 0, math.pi}
    local direction_values = generate_color_values(direction_names, COLOR_AMOUNT)

    local offsets = {
      entrance = Vector(2, 3)
    }
    offsets.exit = offsets.entrance
    local types = {solid = {'block'}, directional = {'spike'}}

    level_manager = LevelManager(
      love.graphics.newImage('resources/maps.png'):getData(),
      love.graphics.newImage('resources/directions.png'):getData(),
      LEVEL_SIZE,
      BLOCK_SIZE,
      sheet_image,
      sprites,
      sprite_speeds,
      default_sprite_speed,
      color_values,
      offsets,
      types,
      direction_values
    )
    level_manager:load_level()
  end

  do
    local display_coordinates = tools.find_center(DISPLAY_SIZE, BLOCK_SIZE)
    local sheet_image = love.graphics.newImage('resources/player_sheet.png')
    local sheet = TileSheet(sheet_image, BLOCK_SIZE)
    local sprites = {
      idle = sheet:get_tiles(2),
      moving = sheet:get_tiles(4),
      pressing = sheet:get_tile(),
      jumping = sheet:get_tile(),
      sliding = sheet:get_tile(),
      dying = sheet:get_equal_sprites(Vector(13, 11), 5)
    }
    local sprite_speeds = {
      idle = .6,
      moving = .15,
      dying = .15
    }
    local keys = {right = 'd', left = 'a', jump = 'w'}
    local movement_speed = 60
    local jump_vector = Vector(.5, -42)
    local wall_jump_vector = Vector(.3, 30)
    player = Player(
      level_manager.entrance.coords,
      display_coordinates,
      BLOCK_VECTOR,
      sheet_image,
      sprites,
      'idle',
      sprite_speeds,
      keys,
      movement_speed,
      jump_vector,
      GRAVITY,
      wall_jump_vector
    )

    love.graphics.translate(display_coordinates:expand())
  end

  love.graphics.scale(SCALES[SCALE_INDEX])
end

function love.update(dt)
  love.event.pump()
  local events = {}
  for name, a, b, c, d, e, f in love.event.poll() do
    if name == 'quit' then
      os.exit(a)
    elseif name == 'keypressed' and a == 'space' then
      os.exit()
    elseif name == 'wheelmoved' then
      game_manager:scale(b)
    end

    if game_manager.phase == 'level' then
      if name == 'keypressed' then
        if a == player.keys['jump'] then
          events[#events + 1] = 'jump'
        end
      end
    end
  end

  if game_manager.phase == 'transitioning' then
    player.coords[1] = player.coords[1] + game_manager.transition_quadratics[game_manager.transition_phase]:execute(dt)

    if game_manager.transition_phase == 1 and player.coords[1] < game_manager.transition_height then
      game_manager.transition_phase = 2

      level_manager:load_level()
      player.coords = level_manager:door_coords('entrance', player)
      player.coords[1] = player.coords[1] - game_manager.transition_height

    elseif game_manager.transition_phase == 2 and game_manager.transition_quadratics[game_manager.transition_phase].completed then
      game_manager:reset_transition()
      game_manager.phase = 'doors'
      game_manager.door = 'entrance'
    end

  elseif game_manager.phase == 'doors' then
    if level_manager[game_manager.door]:update_sprites(dt, false) then
      if game_manager.door == 'entrance' then
        game_manager.phase = 'level'
      else
        game_manager.phase = 'transitioning'
      end
    end

  else
    player:reset_velocity()

    if not player.dead then
      if player.rect and not player:on_ground() then
        player.rect = nil
      end
      if not player.rect and not player.condition then
        player:fall()
      end

      for _, name in pairs(events) do
        if name == 'jump' then
          player:jump()
        end
      end

      if love.keyboard.isDown(player.keys['right']) or love.keyboard.isDown(player.keys['left']) then
        if player.direction ~= 'right' and love.keyboard.isDown(player.keys['right']) then
          player.direction = 1
        elseif player.direction ~= 'left' and love.keyboard.isDown(player.keys['left']) then
          player.direction = -1
        end
      else
        player.direction = nil
      end

      player:move(dt)

      local wall_direction = player.wall_direction
      player.wall_direction = nil
      for _, rect in pairs(level_manager.rects) do
        if player:collided(rect, player:new_coords()) then
          player:process_collision(rect)
        end
      end

      if not wall_direction and player.wall_direction then
        player:slide()
      end

      for _, block in pairs(level_manager.tiles) do
        if block.type == 'spike' then
          if player:collided(block) then
            player.dead = true
            break
          end
        elseif block.type == 'exit' then
          if player:inside(block) then
            game_manager.phase = 'doors'
            game_manager.door = 'exit'
            level_manager.exit.sprite_index = 2
            player.coords = level_manager:door_coords('exit', player)
            player:reset_velocity()
            player:reset_sprites()
          end
        end
      end
      player:update_coords()
      player:update_sprite_type()
    end

    if player:update_sprites(dt) and player.dead then
      player:reset()
    end
  end
end

function love.draw()
  level_manager:display(player.coords)
  if game_manager.phase == 'level' then
    player:display()
  end
end

function love.run()
  love.load()
  love.timer.step()
	while true do
    love.timer.step()
    love.update(love.timer.getDelta())

		love.graphics.clear(love.graphics.getBackgroundColor())
    love.draw()
		love.graphics.present()
		love.timer.sleep(0.001)
	end
end
