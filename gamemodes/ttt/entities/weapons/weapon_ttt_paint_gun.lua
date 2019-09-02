AddCSLuaFile()

DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType               = "shotgun"

if CLIENT then
   SWEP.PrintName           = "Paint Gun"
   SWEP.Slot                = 6

   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 54

   SWEP.EquipMenuData = {
      type = "Paint Gun",
      desc = "Hit a target to paint them purple\n Comes with 5 shots"
   };

   SWEP.Icon               = "vgui/ttt/icon_paint_gun"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Ammo          = "none"
SWEP.Primary.ClipSize      = 5
SWEP.Primary.DefaultClip   = 5
SWEP.Primary.Damage        = 5
SWEP.Primary.Automatic     = false
SWEP.Primary.Delay         = 3
SWEP.Primary.Cone          = 0.005
SWEP.Primary.Sound         = Sound( "weapons/ar2/fire1.wav" )
SWEP.Primary.SoundLevel    = 54

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic   = false
SWEP.Secondary.Ammo        = "none"
SWEP.Secondary.Delay       = 0.5

SWEP.NoSights              = true

SWEP.Kind                  = WEAPON_EQUIP
SWEP.CanBuy                = {ROLE_DETECTIVE, ROLE_TRAITOR}

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel            = "models/weapons/w_shotgun.mdl"

function SWEP:SecondaryAttack()
   return
end

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   if not self:CanPrimaryAttack() then return end
   self:EmitSound(self.Primary.Sound)
   self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
   self:ShootPaintBall()
   self:TakePrimaryAmmo(1)
   if IsValid(self:GetOwner()) then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
      self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
   end

   if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
      self:SetNWFloat( "LastShootTime", CurTime() )
   end
end

function SWEP:Reload()
   return
end

function PaintPlayer(att,tr,dmg)
   local ent = tr.Entity
   if tr.Hitworld then
      util.Decal("YellowBlood",tr.StartPos,tr.HitPos:Add(Vector(1,1,1)))
   end
   if not IsValid(ent) then return end
   if SERVER then
      if ent:IsPlayer() then
         ent:SetPlayerColor(Vector( 138 / 255, 43 / 255, 226 / 255 ))
         ent:SetColor(138,43,226,255)
      else
         ent:SetColor(138,43,226,255)
      end
   end
end

function SWEP:ShootPaintBall()
   local cone = self.Primary.Cone
   local bullet = {}
   bullet.Num       = 1
   bullet.Src       = self:GetOwner():GetShootPos()
   bullet.Dir       = self:GetOwner():GetAimVector()
   bullet.Spread    = Vector( cone, cone, 0 )
   bullet.Tracer    = 1
   bullet.Force     = 2
   bullet.Damage    = self.Primary.Damage
   bullet.TracerName = self.Tracer
   bullet.Callback = PaintPlayer

  self:GetOwner():FireBullets( bullet )
end

