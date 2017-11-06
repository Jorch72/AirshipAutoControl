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
