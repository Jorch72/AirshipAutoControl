motors = require("autocontrol.motors")

----------- Hardware -----------

function HardwareInit()
  print("  Hardware Initialisation ...")
  motors.init()
  print("  Hardware Initialised")
end

--------------------------------