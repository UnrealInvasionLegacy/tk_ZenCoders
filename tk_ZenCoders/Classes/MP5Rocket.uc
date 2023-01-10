class MP5Rocket extends Projectile;

var bool bRing, bHitWater, bWaterStart;
var xEmitter SmokeTrail;
var Effects Corona;
var vector Dir;

simulated function Destroyed()
{
	if (SmokeTrail != None)
		SmokeTrail.mRegen = False;

	if (Corona != None)
		Corona.Destroy();

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'tk_ZenCoders.MP5RocketTrailSmoke',self);
		Corona = Spawn(class'tk_ZenCoders.MP5RocketCorona',self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity = 0.6*Velocity;
	}

	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (Level.bDropDetail || (Level.DetailMode == DM_Low))
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if ((Instigator != None) && (PC == Instigator.Controller))
			return;

		if ((PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000))
		{
			bDynamicLight = false;
			LightType = LT_None;
		}
	}
}

simulated function Landed(vector HitNormal)
{
	Explode(Location, HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ((Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget))
		Explode(HitLocation, vector(rotation)*-1);
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',,1.5*TransientSoundVolume);
	if (EffectIsRelevant(Location, false))
	{
		Spawn(class'tk_ZenCoders.MP5RocketExplosion',,,HitLocation + HitNormal*20,rotator(HitNormal));
		PC = Level.GetLocalPlayerController();
		if ((PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000)
			Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
	}

	BlowUp(HitLocation);
	Destroy();
}

defaultproperties
{
     Speed=1350.000000
     MaxSpeed=1350.000000
     Damage=90.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'tk_ZenCoders.DamTypeMP5Rocket'
     ExplosionDecal=Class'XEffects.RocketMark'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=140
     LightBrightness=255.000000
     LightRadius=5.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     CullDistance=7500.000000
     bDynamicLight=True
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=8.000000
     DrawScale3D=(Y=0.500000,Z=0.500000)
     Skins(0)=Texture'WeaponSkins.AmmoPickups.BioRiflePickup'
     AmbientGlow=64
     FluidSurfaceShootStrengthMod=6.000000
     SoundVolume=160
     SoundPitch=192
     SoundRadius=96.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}