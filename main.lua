-- Fonction qui contient les caractéristiques de la cible.
function Set_Target(p_table)
  p_table.x = Random_Range(200, largeur)
  p_table.y = hauteur
  p_table.rayon = Random_Range(10, 40)
end

-- Fonction qui gère les forces à appliquer à un boulet au moment du tir.
function Shoot(p_value, p_munition, p_canon)
  local force = Map(p_value, -1, 1, 2, 20)
  p_munition.position.x = p_canon.x + math.cos(p_canon.angle)*40
  p_munition.position.y = p_canon.y + math.sin(p_canon.angle)*40
  p_munition.Set_Speed(force)
  p_munition.Set_Heading(p_canon.angle)
end

-- Fonction qui permet de diriger le canon.
function Aim_Gun(p_mouse_x, p_mouse_y, p_canon)
  p_canon.angle = Clamp(math.atan2(p_mouse_y-p_canon.y, p_mouse_x-p_canon.x), -math.pi/2, -0.3)
end

-- Fonction qui vérifie si un boulet entre en collision avec la cible.
function Check_Target(p_mun, p_table)
  if Circle_Collision(p_mun.position.x, p_mun.position.y, p_table.x, p_table.y, p_mun.rayon, p_table.rayon) then
    Set_Target(p_table)
  end
end

-- Objet qui crée un tout petit jeu qui consiste à tirer dans une cible.
function Shoot_Game(gx, gy, g_angle, g_img, p_rayon, p_speed, p_gravite)
  local gun = {}
  gun.x = gx
  gun.y = gy
  gun.angle = g_angle
  gun.img = g_img
  function Load_Gun()
    love.graphics.setCanvas(gun.img)
    love.graphics.rectangle("fill", 0, 0, gun.img:getWidth(), gun.img:getHeight())
    love.graphics.setCanvas()
  end
  local cannonball = Particule(gun.x, gun.y, 0, 0, p_rayon, 0, 0, 0, 0, p_speed, gun.angle, p_gravite)
  local is_shooting = false
  local force_angle = 0
  local force_speed = 0.1
  local raw_force = 0
  local target = {}
  target.x = Random_Range(200, largeur)
  target.y = hauteur
  target.rayon = Random_Range(10, 40)
  
  local ghost = {}
  ghost.Init = function()
    Set_Target(target)
    Load_Gun()
  end
  ghost.Update = function(dt)
    if is_shooting == false then
      force_angle = force_angle + force_speed
    end
    
    raw_force = math.sin(force_angle)
    if is_shooting then
      cannonball.Update(dt)
      Check_Target(cannonball, target)
    end
    
    if cannonball.position.y+cannonball.rayon > hauteur then
      is_shooting = false
    end
  end
  ghost.Draw = function()
    love.graphics.rectangle("fill", 10, hauteur-10, 20, -100)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", 10, hauteur-10, 20, Map(raw_force, -1, 1, 0, -100))
    love.graphics.setColor(1, 1, 1)
    
    love.graphics.circle("fill", gun.x, gun.y, 24)
    love.graphics.draw(gun.img, gun.x, gun.y-8, gun.angle)
    love.graphics.circle("fill", cannonball.position.x, cannonball.position.y, cannonball.rayon)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("line", target.x, target.y, target.rayon)
    love.graphics.setColor(1, 1, 1)
  end
  ghost.Fire = function(p_key)
    if p_key == "space" then
      if is_shooting == false then
        Shoot(raw_force, cannonball, gun)
        is_shooting = true
      end
    end
  end
  ghost.Move_Canon = function(px, py, p_button)
    if p_button == 1 then
      Aim_Gun(px, py, gun)
    end
  end
  return ghost
end