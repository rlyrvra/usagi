-- main.lua — Dual-sprite WASD / IJKL animation test
--
-- sprites/player.png: 11 frames × 256×256, single row (sheet 2816×256)
-- sprites/enemy.png :  5 frames × 256×256, single row (sheet 1280×256)
--
-- WASD drives `player`; IJKL drives `enemy`.
-- Frame 1 = idle. Moving cycles frames 1..N.

local W, H = usagi.GAME_W, usagi.GAME_H

-- Source-frame dimensions (the art itself).
local FRAME_W, FRAME_H = 256, 256

-- Display size in game pixels. The 256×256 art is heavily downscaled.
-- Bump this if 32 looks too small on your palette.
local DISPLAY_SIZE = 32

-- Seconds per animation frame. 0.10 ≈ 10 fps. Tweak to taste.
local FRAME_TIME = 0.10

local player = {
  x =  40, y =  70, speed = 90,
  frames = 11, frame = 1, anim_t = 0,
  flip_x = false,
}
local enemy = {
  x = 220, y =  70, speed = 90,
  frames = 5,  frame = 1, anim_t = 0,
  flip_x = false,
}

local function clamp(ent)
  if ent.x < 0                then ent.x = 0                end
  if ent.y < 0                then ent.y = 0                end
  if ent.x > W - DISPLAY_SIZE then ent.x = W - DISPLAY_SIZE end
  if ent.y > H - DISPLAY_SIZE then ent.y = H - DISPLAY_SIZE end
end

local function advance_anim(ent, dt, moving)
  if moving then
    ent.anim_t = ent.anim_t + dt
    -- `while` (not `if`) so big dt doesn't drop frames.
    while ent.anim_t >= FRAME_TIME do
      ent.anim_t = ent.anim_t - FRAME_TIME
      ent.frame = ent.frame + 1
      if ent.frame > ent.frames then ent.frame = 1 end
    end
  else
    ent.frame = 1
    ent.anim_t = 0
  end
end

local function update_entity(ent, dt, kleft, kright, kup, kdown)
  local moving = false

  if input.key_held(kleft)  then
    ent.x = ent.x - ent.speed * dt
    ent.flip_x = true
    moving = true
  end
  if input.key_held(kright) then
    ent.x = ent.x + ent.speed * dt
    ent.flip_x = false
    moving = true
  end
  if input.key_held(kup)    then ent.y = ent.y - ent.speed * dt; moving = true end
  if input.key_held(kdown)  then ent.y = ent.y + ent.speed * dt; moving = true end

  clamp(ent)
  advance_anim(ent, dt, moving)
end

local function draw_entity(ent, name)
  local sx = (ent.frame - 1) * FRAME_W         -- 0-based left edge of slice
  gfx.img_sspr_ex(
    name,                                      -- source image
    sx, 0, FRAME_W, FRAME_H,                   -- source rect
    math.floor(ent.x), math.floor(ent.y),      -- dest pos
    DISPLAY_SIZE, DISPLAY_SIZE,                -- dest size (downscale)
    ent.flip_x, false,                         -- flip
    0,                                         -- rotation
    gfx.COLOR_TRUE_WHITE,                      -- identity tint
    1.0                                        -- alpha
  )
end

function _init()
  player.x, player.y =  40,  70
  player.frame, player.anim_t, player.flip_x = 1, 0, false
  enemy.x,  enemy.y  = 220,  70
  enemy.frame,  enemy.anim_t,  enemy.flip_x  = 1, 0, false
end

function _update(dt)
  update_entity(player, dt, input.KEY_A, input.KEY_D, input.KEY_W, input.KEY_S)
  update_entity(enemy,  dt, input.KEY_J, input.KEY_L, input.KEY_I, input.KEY_K)
end

function _draw()
  gfx.clear(gfx.COLOR_DARK_BLUE)

  draw_entity(player, "player")
  draw_entity(enemy,  "enemy")

  gfx.rect(0, 0, W, H, gfx.COLOR_WHITE)

  gfx.text("WASD: player   IJKL: enemy", 6, 4, gfx.COLOR_WHITE)
  gfx.text(
    string.format("P f%d/11   E f%d/5", player.frame, enemy.frame),
    6, 18, gfx.COLOR_LIGHT_GRAY
  )
end