class BenelliShell extends Projectile;

var xEmitter Trail;
var byte Bounces;
var float DamageAtten;
var sound ImpactSounds[6];

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		Bounces;
}

simulated function Destroyed()
{
	if (Trail != None)
		Trail.mRegen = False;

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (!PhysicsVolume.bWaterVolume)
		{
			Trail = Spawn(class'FlakTrail', self);
			Trail.Lifespan = Lifespan;
		}
	}

	Velocity = Vector(Rotation) * (Speed);
	if (PhysicsVolume.bWaterVolume)
		Velocity *= 0.65;

	SetRotation(RotRand());

	Super.PostBeginPlay();
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	Explode(HitLocation, vector(rotation)*-1);
}

simulated function HitWall(vector HitNormal, Actor Wall)
{
	local PlayerController PC;

	if (Role == ROLE_Authority)
	{
		if (!Wall.bStatic && !Wall.bWorldGeometry)
		{
			if (Instigator == None || Instigator.Controller == None)
				Wall.SetDelayedDamageInstigatorController(InstigatorController);

			Wall.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);

			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}

	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ((ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer))
	{
		if (ExplosionDecal.default.CullDistance != 0)
		{
			PC = Level.GetLocalPlayerController();
			if (!PC.BeyondViewDistance(Location, ExplosionDecal.default.CullDistance))
				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
			else if ((Instigator != None) && (PC == Instigator.Controller) && !PC.BeyondViewDistance(Location, 2*ExplosionDecal.default.CullDistance))
				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
		}
		else
		{
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
		}
	}
	HurtWall = None;
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(ImpactSounds[Rand(6)],,1.0*TransientSoundVolume);
	if (EffectIsRelevant(Location, false))
	{
		Spawn(class'SmallExplosion',,,HitLocation + HitNormal*20,rotator(HitNormal));
		PC = Level.GetLocalPlayerController();
		if ((PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000)
			Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
	}

	BlowUp(HitLocation);
	Destroy();
}

simulated function Landed(Vector HitNormal)
{
	Explode(Location, HitNormal);
}

simulated function PhysicsVolumeChange(PhysicsVolume Volume)
{
	if (Volume.bWaterVolume)
	{
		if (Trail != None)
			Trail.mRegen = False;
		Velocity *= 0.65;
	}
}

defaultproperties
{
     DamageAtten=1.000000
     ImpactSounds(0)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact5'
     ImpactSounds(1)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact6'
     ImpactSounds(2)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact13'
     ImpactSounds(3)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact11'
     ImpactSounds(4)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact12'
     ImpactSounds(5)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact7'
     Speed=10000.000000
     MaxSpeed=10000.000000
     Damage=10.000000
     DamageRadius=96.000000
     MomentumTransfer=6000.000000
     MyDamageType=Class'tk_ZenCoders.DamTypeBenelliChunk'
     LifeSpan=2.000000
     DrawScale=0.750000
}