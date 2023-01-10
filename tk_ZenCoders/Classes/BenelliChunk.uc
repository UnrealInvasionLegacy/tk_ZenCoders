class BenelliChunk extends Projectile;

var xEmitter Trail;
var vector initialDir;
var Actor Glow;
var Sound ImpactSounds[6];

simulated function PostBeginPlay()
{
	local Rotator R;
	local PlayerController PC;

	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if ((PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000)
			Trail = Spawn(class'FlakTrail',self);

		Glow = Spawn(class'BenelliGlow', self);
	}

	Super.PostBeginPlay();

	Velocity = Vector(Rotation) * Speed;
	R = Rotation;
	R.Roll = 32768;
	SetRotation(R);
	initialDir = Velocity;
}

simulated function destroyed()
{
	if (Trail != None) 
		Trail.mRegen = False;

	if (Glow != None)
		Glow.Destroy();

	Super.Destroyed();
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Other != Instigator)
	{
		SpawnEffects(HitLocation, -1 * Normal(Velocity));
		Explode(HitLocation, Normal(HitLocation - Other.Location));
	}
}

simulated function SpawnEffects(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(ImpactSounds[Rand(6)],,1.0*TransientSoundVolume);
	if (EffectIsRelevant(Location, false))
	{
		PC = Level.GetLocalPlayerController();
		if ((PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 3000)
			Spawn(class'SmallExplosion',,,HitLocation + HitNormal*16);

		Spawn(class'SmallExplosion',,,HitLocation + HitNormal*16);
		Spawn(class'WallSparks',,,HitLocation + HitNormal*16, rotator(HitNormal));
		if ((ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer))
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
}

simulated function Landed( vector HitNormal )
{
	SpawnEffects(Location, HitNormal);
	Explode(Location, HitNormal);
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	Landed(HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (Role == ROLE_Authority)
		ExtendedHurtRadius(HitLocation, Normal(Velocity), None);

	Destroy();
}

function ExtendedHurtRadius(vector HitLocation, vector AimDir, Actor HitActor)
{
	local Pawn Victims;
	local float damageScale, dist, damageAmount;
	local vector dir;

	damageAmount = RandRange(Damage-6, Damage+6);
	foreach VisibleCollidingActors(class'Pawn', Victims, DamageRadius + 200, HitLocation)
	{
		if (Victims != self && Victims.Role == ROLE_Authority && !Victims.IsA('FluidSurfaceInfo'))
		{
			dist = DistToCylinder(Victims.Location - HitLocation, Victims.CollisionHeight, Victims.CollisionRadius);
			if (dist > DamageRadius)
				continue;

			dir = Normal(Victims.Location - HitLocation);
			if (Victims == HitActor)
				dir = Normal(dir + AimDir);

			damageScale = 1 - FMax(0, dist / DamageRadius);
			Victims.TakeDamage(damageScale * damageAmount, Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, damageScale * MomentumTransfer * dir, MyDamageType);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(damageAmount, DamageRadius, Instigator.Controller, MyDamageType, MomentumTransfer, HitLocation);
		}
	}
}

static final function float DistToCylinder(vector CenterDist, float HalfHeight, float Radius)
{
	CenterDist.X = VSize(vect(1,1,0) * CenterDist) - Radius;
	if (CenterDist.X < 0)
		CenterDist.X = 0;
	
	CenterDist.Y = 0;
	if (CenterDist.Z < 0)
		CenterDist.Z *= -1;
	
	CenterDist.Z -= HalfHeight;
	if (CenterDist.Z < 0)
		CenterDist.Z = 0;
	
	return VSize(CenterDist);
}

defaultproperties
{
     ImpactSounds(0)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact5'
     ImpactSounds(1)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact6'
     ImpactSounds(2)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact13'
     ImpactSounds(3)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact11'
     ImpactSounds(4)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact12'
     ImpactSounds(5)=Sound'WeaponSounds.BaseImpactAndExplosions.BBulletImpact7'
     Speed=5000.000000
     MaxSpeed=5000.000000
     Damage=12.000000
     DamageRadius=64.000000
     MomentumTransfer=6000.000000
     MyDamageType=Class'tk_ZenCoders.DamTypeBenelliChunk'
     ExplosionDecal=Class'tk_ZenCoders.BenelliMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakShell'
     CullDistance=4000.000000
     AmbientSound=Sound'WeaponSounds.BaseProjectileSounds.BFlakCannonProjectile'
     LifeSpan=2.500000
     AmbientGlow=100
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     ForceType=FT_Constant
     ForceRadius=60.000000
     ForceScale=5.000000
}