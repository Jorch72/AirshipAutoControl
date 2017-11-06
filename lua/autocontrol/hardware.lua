loadfile("motors.lua")

----------- Hardware -----------

function HardwareInit()
  print("  Hardware Initialisation ...")
  MotorsInit()
  print("  Hardware Initialised")
end
