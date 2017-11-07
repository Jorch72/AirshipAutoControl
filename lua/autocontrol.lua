-- Olivier Leblanc-Pellerin
-- Automatic Airship Control
-- Version 0.0.1

os = require("os")

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
  if speed > 100 then
    return 100
  elseif speed < -100 then
    return -100
  end
	return speed
end

function mtr_L(speed)
  speed = normaliseSpeed(speed)
end

function mtr_R(speed)
  speed = normaliseSpeed(speed)
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
    os.sleep(1)
  end
end
main()
