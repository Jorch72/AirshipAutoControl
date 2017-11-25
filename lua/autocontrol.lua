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
mtr_l(%)   pourcentage of the maximum speed of the craft applied to the left motor
mtr_r(%)   pourcentage of the maximum speed of the craft applied to the right motor
mtr_spin(%)      + clockwise, - counterclockwise.
]]


------- Global variables -------

local MAIN_LOOP = true

local cur_pos    = { x=0, y=0, z=0 } -- (x, y, z)
local target_pos = { x=0, y=0, z=0 } -- (x, y, z)

local yaw   = 0
local roll  = 0
local pitch = 0

local linear_speed  = 0        -- meters per second
local angular_speed = 0

local user_input = nil

local goToDest   = false

local target_yaw = 0

--------------------------------
------------ Motors ------------

local function MotorsInit()
  if not component.isAvailable("redstone") then
    print("redstone component not available!")
    os.exit(1)
  end
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
  redstone.setOutput(sides.right,speed)
end

local function mtr_r(speed)             --mtr_r
  speed = normaliseSpeed(speed)
  redstone.setOutput(sides.left,speed)
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

local function mtr_brake()
  --WIP
  
  mtr_l(0)
  mtr_r(0)
end
--------------------------------
----------- Hardware -----------

local function HardwareInit()
  MotorsInit()
  if not component.isAvailable("ship_interface") then
    print("ship_interface component not available!")
    os.exit(1)
  end
end
--------------------------------
------------ System ------------

local function SystemInit()
  HardwareInit()
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function distance(a, b)
  if (type(a)~="table" or type(b)~="table") then  return -1  end
  return math.sqrt((a[1]-b[1])^2 + (a[2]-b[2])^2 + (a[3]-b[3])^2)
end

local function AutoTravel()
  -- The x and z coordinates change places 
  -- Ex : before -> (x, z)
  --      now    -> (z, x)
  local normalised_yaw = yaw + 180
  local delta_X, delta_Y = (cur_pos.z - target_pos.z), (target_pos.x - cur_pos.x)
  
  target_yaw = math.atan(math.abs(delta_Y / delta_X))
  if delta_X < 0 and delta_Y > 0 then
    target_yaw = target_yaw - 180
  elseif delta_X < 0 and delta_Y < 0 then
    target_yaw = target_yaw + 180
  elseif delta_X > 0 and delta_Y < 0 then
    target_yaw = 360 - target_yaw
  end
  
  local angle_diff  = normalised_yaw - target_yaw
  
  mtr_speed(1)
  
  target_yaw = target_yaw - 180
end

local function Update()
  local x1, y1, z1 = ship.getPosition()
  local yaw1 = ship.getYaw()
  os.sleep(1)
  local x2, y2, z2 = ship.getPosition()
  local yaw2  = ship.getYaw() + 180
  if yaw2 > 180 then  yaw2 = yaw2 - 360  end
  linear_speed  = distance({x1, y1, z1}, {x2, y2, z2})
  angular_speed = math.abs(yaw1 - yaw2)
  
  cur_pos.x, cur_pos.y, cur_pos.z = ship.getPosition()
  
  yaw   = ship.getYaw() + 180
  if yaw > 180 then  yaw = yaw - 360  end
  
  roll  = ship.getRoll()
  pitch = ship.getPitch()
end

local function Draw()
  --Gui Handling--
  if component.isAvailable("gpu") then
    local cursor_X, cursor_Y = term.getCursor()
    
    for i=1, 8 do
      term.setCursor(1, i)
      term.clearLine()
    end
    term.setCursor(1,1)
    term.write("cur_pos       : "..round(cur_pos.x,2)..", "..round(cur_pos.y,2)..", "..round(cur_pos.z,2))
    term.setCursor(1,2)
    term.write("target_pos    : "..round(target_pos.x,2)..", "..round(target_pos.y,2)..", "..round(target_pos.z,2))
    term.setCursor(1,3)
    term.write("Distance      : "..round(distance({cur_pos.x,cur_pos.y,cur_pos.z}, {target_pos.x,target_pos.y,target_pos.z}),4).." m")
    term.setCursor(1,4)
    term.write("Yaw           : "..round(yaw, 4).." deg")
    term.setCursor(1,5)
    term.write("Linear speed  : "..round(linear_speed, 4).." m/s")
    term.setCursor(1,6)
    term.write("Angular speed : "..round(angular_speed, 4).." deg/s")
    term.setCursor(1,7)
    term.write("target_yaw    : "..round(target_yaw, 4).." deg")
    
    
    term.setCursor(1,8)
    term.write("----------------")
    term.setCursor(cursor_X, cursor_Y)
  end
end
--------------------------------

local main_thread = thread.create(function()
  SystemInit()
  
  while MAIN_LOOP do
    Update()
    Draw()
    os.sleep(0)
    
    if goToDest then
      AutoTravel()
    else
      mtr_brake()
    end
  end
end)

local user_input_thread = thread.create(function()
  term.setCursor(1, 9)
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
    elseif user_input == "start travel" then
      goToDest = true;
    elseif user_input == "stop travel" then
      goToDest = false;
    end
  end
end)

thread.waitForAny({ main_thread, user_input_thread })
mtr_brake()
os.exit(0)
