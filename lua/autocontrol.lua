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
mtr_brake()

--[[
mtr_speed(%)     pourcentage of the maximum speed of the craft applied to both motors
mtr_l(%)   pourcentage of the maximum speed of the craft applied to the left motor
mtr_r(%)   pourcentage of the maximum speed of the craft applied to the right motor
mtr_spin(%)      + clockwise, - counterclockwise.
]]


------- Global variables -------

local MAIN_LOOP        = true

local cur_pos          = { x=0, y=0, z=0 } -- (x, y, z)
local target_pos       = { x=0, y=0, z=0 } -- (x, y, z)

local yaw   = ship.getYaw()
local roll  = ship.getRoll()
local pitch = ship.getPitch()

local linear_speed = 0        -- meters per second
local angular_speed = 0

local user_input       = nil
local user_input_ready = true

local goToDest         = false

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
  elseif not component.isAvailable("gpu") then
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
  return math.sqrt(math.pow(a[1]-b[1],2)+math.pow(a[2]-b[2],2)+math.pow(a[3]-b[3],2))
end

local function AutoTravel()
  local target_yaw = math.atan((cur_pos.x - target_pos.x) / (cur_pos.z - target_pos.z))
  local angle_diff  = yaw - target_yaw
  
  mtr_speed(1)
  
  if ((angle_diff < 170 and angle_diff > 0)         -- Turn left
  or (angle_diff >= -170 and angle_diff <= 0 )) then
    mtr_r(0)
  elseif ((angle_diff > 170 and angle_diff > 0)     -- Turn right
  or (angle_diff <= -170 and angle_diff <= 0 )) then
    mtr_l(1)
  end
end

local function Update()
  cur_pos.x, cur_pos.y, cur_pos.z = ship.getPosition()
  
  linear_speed = ship.getLinearSpeed()
  angular_speed = ship.getAngularSpeed()
  
  yaw   = ship.getYaw()
  roll  = ship.getRoll()
  pitch = ship.getPitch()
end

local function Draw()
  --Gui Handling--
  local cursor_X, cursor_Y = term.getCursor()
  
  for i=1,6 do
    term.setCursor(1, i)
    term.clearLine()
  end
  term.setCursor(1,1)
  term.write("cur_pos    : "..round(cur_pos.x,2)..", "..round(cur_pos.y,2)..", "..round(cur_pos.z,2))
  term.setCursor(1,2)
  term.write("target_pos : "..round(target_pos.x,2)..", "..round(target_pos.y,2)..", "..round(target_pos.z,2))
  term.setCursor(1,3)
  term.write("Distance   : "..round(distance({cur_pos.x,cur_pos.y,cur_pos.z}, {target_pos.x,target_pos.y,target_pos.z}),4).." m")
  term.setCursor(1,4)
  term.write("Yaw        : "..round(yaw, 4))
  term.setCursor(1,5)
  term.write("Speed      : "..round(linear_speed, 4).." m/s")
  
  
  
  term.setCursor(term.window.width/4,6)
  for i=1,term.window.width/2 do
    term.write("-")
  end
  term.setCursor(cursor_X, cursor_Y)
end
--------------------------------

local main_thread = thread.create(function()
  SystemInit()
  
  while MAIN_LOOP do
    Update()
    Draw()
    
    if goToDest then
      AutoTravel()
    else
      mtr_brake()
    end
    
    os.sleep(0)
  end
end)

local user_input_thread = thread.create(function()
  term.setCursor(1, 7)
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
