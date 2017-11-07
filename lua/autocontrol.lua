-- Olivier Leblanc-Pellerin
-- Automatic Airship Control
-- Version 0.0.1

os = require("os")
redstone = require("component.redstone")
sides = require("sides")

--[[
mtr_speed(%)     pourcentage of the maximum speed of the craft applied to both motors
mtr_L_speed(%)   pourcentage of the maximum speed of the craft applied to the left motor
mtr_R_speed(%)   pourcentage of the maximum speed of the craft applied to the right motor
mtr_spin(%)      + clockwise, - counterclockwise.
]]

------- Global variables -------

MAIN_LOOP = true
--------------------------------
------------ Motors ------------

function MotorsInit()
  print("    Motors Initialisation ...")
  
  print("    Motors Initialised")
end

function normaliseSpeed(speed)
  if speed > 15 then
    return 15
  elseif speed < 0 then
    return 0
  end
	return speed
end

function mtr_L(speed)
  speed = normaliseSpeed(speed)
  redstone.setOutput(sides.left,speed)
end

function mtr_R(speed)
  speed = normaliseSpeed(speed)
  redstone.setOutput(sides.right,speed)
end

function mtr_speed(speed)
  speed = normaliseSpeed(speed)
  mtr_L(speed)
  mtr_R(speed)
end

function mtr_spin(speed)
  speed = normaliseSpeed(speed)
  mtr_L(speed)
  mtr_R(-speed)
end
--------------------------------
----------- Hardware -----------

function HardwareInit()
  print("  Hardware Initialisation ...")
  MotorsInit()
  print("  Hardware Initialised")
end
--------------------------------
------------ System ------------

function SystemInit()
  print("System Initialisation ...")
  HardwareInit()
  print("System Initialised")
end
--------------------------------

function main()
  SystemInit()
  
  while MAIN_LOOP do
    mtr_L(1)
  end
end
main()
