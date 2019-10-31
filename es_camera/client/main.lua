local Spectating      = {}
local InSpectatorMode = false
local TargetSpectate  = nil
local LastPosition    = nil
local polarAngleDeg   = 0;
local azimuthAngleDeg = 90;
local radius          = -3.5;
local cam             = nil

function polar3DToWorld3D(entityPosition, radius, polarAngleDeg, azimuthAngleDeg)
    
    -- convert degrees to radians
    
    local polarAngleRad   = polarAngleDeg   * math.pi / 180.0
    local azimuthAngleRad = azimuthAngleDeg * math.pi / 180.0

    local pos = {
      x = entityPosition.x + radius * (math.sin(azimuthAngleRad) * math.cos(polarAngleRad)),
      y = entityPosition.y - radius * (math.sin(azimuthAngleRad) * math.sin(polarAngleRad)),
      z = entityPosition.z - radius * math.cos(azimuthAngleRad)
    }

    return pos
end

function spectate(target)

  if not InSpectatorMode then
    LastPosition = GetEntityCoords(GetPlayerPed(-1))
  end

  local playerPed = GetPlayerPed(-1)

  SetEntityCollision(playerPed,  false,  false)
  SetEntityVisible(playerPed,  false)

  Citizen.CreateThread(function()
    
    if not DoesCamExist(cam) then
      cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    SetCamActive(cam,  true)
    RenderScriptCams(true,  false,  0,  true,  true)

    InSpectatorMode = true
    TargetSpectate  = target

  end)

end

function resetNormalCamera()

  InSpectatorMode = false
  TargetSpectate  = nil
  local playerPed = GetPlayerPed(-1)

  SetCamActive(cam,  false)
  RenderScriptCams(false,  false,  0,  true,  true)

  SetEntityCollision(playerPed,  true,  true)
  SetEntityVisible(playerPed,  true)
  SetEntityCoords(playerPed, LastPosition.x, LastPosition.y, LastPosition.z)
end

AddEventHandler('playerSpawned', function()
  TriggerServerEvent('es_camera:requestSpectating')
end)

RegisterNetEvent('es_camera:spectate')
AddEventHandler('es_camera:spectate', function(target)

  if InSpectatorMode and target == -1 then
    resetNormalCamera()
  end

  if target ~= -1 then
    spectate(target)
  end

end)


RegisterNetEvent('es_camera:onSpectate')
AddEventHandler('es_camera:onSpectate', function(spectating)
  Spectating = spectating
end)

Citizen.CreateThread(function()

  while true do

    Wait(0)

    if InSpectatorMode then

      local targetPlayerId = GetPlayerFromServerId(TargetSpectate)
      local playerPed      = GetPlayerPed(-1)
      local targetPed      = GetPlayerPed(targetPlayerId)
      local coords         = GetEntityCoords(targetPed)

      for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
          local otherPlayerPed = GetPlayerPed(player)
          SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
        end
      end

      if IsControlPressed(2, 241) then
        radius = radius + 0.5;
      end

      if IsControlPressed(2, 242) then
        radius = radius - 0.5;
      end

      if radius > -1 then
        radius = -1
      end

      local xMagnitude = GetDisabledControlNormal(0,  1);
      local yMagnitude = GetDisabledControlNormal(0,  2);

      polarAngleDeg = polarAngleDeg + xMagnitude * 10;

      if polarAngleDeg >= 360 then
        polarAngleDeg = 0
      end

      azimuthAngleDeg = azimuthAngleDeg + yMagnitude * 10;

      if azimuthAngleDeg >= 360 then
        azimuthAngleDeg = 0;
      end

      local nextCamLocation = polar3DToWorld3D(coords, radius, polarAngleDeg, azimuthAngleDeg)

      SetCamCoord(cam,  nextCamLocation.x,  nextCamLocation.y,  nextCamLocation.z)
      PointCamAtEntity(cam,  targetPed)
      SetEntityCoords(playerPed,  coords.x, coords.y, coords.z + 10)

    end

  end
end)