class MP5Fire extends tk_InstantFire;

var float LastFireTime;
var float ClickTime;

function InitEffects()
{
	Super.InitEffects();
	if (FlashEmitter != None)
		Weapon.AttachToBone(FlashEmitter, 'tip');
}

function FlashMuzzleFlash()
{
	local rotator r;

	r.Roll = (0);
	Weapon.SetBoneRotation('Bone_Flash', r, 0, 1.f);
	Super.FlashMuzzleFlash();
}

event ModeDoFire()
{
	if (Level.TimeSeconds - LastFireTime > 0.25)
		Spread = default.Spread;
	else
		Spread = FMin(Spread + 0.01, 0.04);

	LastFireTime = Level.TimeSeconds;
	Super.ModeDoFire();
}

simulated function bool AllowFire()
{
	if (Super.AllowFire())
	{
		return true;
	}
	else
	{
		if ((PlayerController(Instigator.Controller) != None) && (Level.TimeSeconds > ClickTime))
		{
			Instigator.PlaySound(Sound'WeaponSounds.P1Reload5');
			ClickTime = Level.TimeSeconds + 0.25;
		}
		return false;
	}
}

defaultproperties
{
     DamageType=Class'tk_ZenCoders.DamTypeMP5Bullet'
     DamageMin=18
     DamageMax=20
     Momentum=0.000000
     bPawnRapidFireAnim=True
     FireSound=Sound'tk_ZenCoders.Zen.MP5Snd'
     FireForce="AssaultRifleFire"
     FireRate=0.166000
     AmmoClass=Class'tk_ZenCoders.MP5Ammo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'XEffects.AssaultMuzFlash1st'
     aimerror=800.000000
     SpreadStyle=SS_Random
}