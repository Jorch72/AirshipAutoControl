------------ Motors ------------

function init()
  print("  Motors Initialisation ...")
  
  print("  Motors Initialised")
end

local function normaliseSpeed(speed)
  if speed > 100 then
    speed = 100
  elseif (speed < -100) then
    speed = -100
  end
  end
end

function mtr_L(speed)
  normaliseSpeed(speed)
end

function mtr_R(speed)
  normaliseSpeed(speed)
end

function mtr_speed(speed)
  normaliseSpeed(speed)
  mtr_L(speed)
  mtr_R(speed)
end

function mtr_spin(speed)
  normaliseSpeed(speed)
  mtr_L(speed)
  mtr_R(-speed)
end

