-- Olivier Leblanc-Pellerin
-- Automatic Airship Control
-- Version 0.0.1

term = require("term")
thread = require("thread")
component = require("component")
redstone = component.redstone
ship = component.ship_interface
sides = require("sides")
term.clear()

--[[
mtr_speed(%)     pourcentage of the maximum speed of the craft applied to both motors
mtr_L_speed(%)   pourcentage of the maximum speed of the craft applied to the left motor
mtr_R_speed(%)   pourcentage of the maximum speed of the craft applied to the right motor
mtr_spin(%)      + clockwise, - counterclockwise.
]]


------- Global variables -------

local MAIN_LOOP        = true
local cur_pos          = { x=0, y=0, z=0 } -- (x, y, z)
local target_pos       = { x=0, y=0, z=0 } -- (x, y, z)
local user_input       = nil
local user_input_ready = true

--------------------------------
------------ Motors ------------

local function MotorsInit()
  print("    Motors Initialisation ...")
  
  print("    Motors Initialised")
end

local function normaliseSpeed(speed)
  if speed > 15 then
    return 15
  elseif speed < 0 then
    return 0
  end
  return speed
end

local function mtr_l(speed)             --mtr_l
  speed = normaliseSpeed(speed)
  redstone.setOutput(sides.left,speed)
end

local function mtr_r(speed)             --mtr_r
  speed = normaliseSpeed(speed)
  redstone.setOutput(sides.right,speed)
end

local function mtr_speed(speed)         --mtr_speed
  speed = normaliseSpeed(speed)
  mtr_l(speed)
  mtr_r(speed)
end

local function mtr_spin(speed)           --mtr_spin
  speed = normaliseSpeed(speed)
  mtr_l(speed)
  mtr_r(-speed)
end
--------------------------------
----------- Hardware -----------

local function HardwareInit()
  print("  Hardware Initialisation ...")
  MotorsInit()
  print("  Hardware Initialised")
end
--------------------------------
------------ System ------------

local function SystemInit()
  print("System Initialisation ...")
  HardwareInit()
  print("System Initialised")
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function distance(a, b)
  if (type(a)~="table" or type(b)~="table") then  return -1  end
  return math.sqrt(math.pow(a[1]-b[1],2)+math.pow(a[2]-b[2],2)+math.pow(a[3]-b[3],2))
end
function distance(a, b)
  return math.sqrt(math.pow(a[1]-b[1],2)+math.pow(a[2]-b[2],2)+math.pow(a[3]-b[3],2))
end
local function Update()
  cur_pos.x, cur_pos.y, cur_pos.z = ship.getPosition()
  
  --Gui Handling--
  local cursor_X, cursor_Y = term.getCursor()
  
  for i=1,19 do
    term.setCursor(1, i)
    term.clearLine()
  end
  term.setCursor(1,1)
  term.write("cur_pos    : "..round(cur_pos.x,2)..", "..round(cur_pos.y,2)..", "..round(cur_pos.z,2))
  term.setCursor(1,2)
  term.write("target_pos : "..round(target_pos.x,2)..", "..round(target_pos.y,2)..", "..round(target_pos.z,2))
  term.setCursor(1,3)
  term.write("Distance   : "..round(distance({cur_pos.x,cur_pos.y,cur_pos.z}, {target_pos.x,target_pos.y,target_pos.z}),4).." m")
  
  
  term.setCursor(1,19)
  for i=1,term.window.width do
    term.write("-")
  end
  term.setCursor(cursor_X, cursor_Y)
  os.sleep(0)
end
--------------------------------

local main_thread = thread.create(function()
  SystemInit()
  
  while MAIN_LOOP do
    Update()
  end
end)

local user_input_thread = thread.create(function()
  term.setCursor(1, 20)
  while user_input~="exit" do
    io.write("> ")
    user_input = io.read()
    
    if user_input == "change target" then
      io.write("  x: ")
      target_pos.x = io.read()
      io.write("  y: ")
      target_pos.y = io.read()
      io.write("  z: ")
      target_pos.z = io.read()
    elseif user_input == "change position" then
      io.write("  x: ")
      cur_pos.x = io.read()
      io.write("  y: ")
      cur_pos.y = io.read()
      io.write("  z: ")
      cur_pos.z = io.read()
    end
  end
end)

thread.waitForAny({ main_thread, user_input_thread })
os.exit(0)
