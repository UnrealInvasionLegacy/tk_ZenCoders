class MP5Grenade extends Projectile;

var float ExplodeTimer, LastSparkTime;
var bool bTimerSet, bCanHitOwner, bHitWater;
var xEmitter Trail;
var() float DampenFactor, DampenFactorParallel;
var class<xEmitter> HitEffectClass;

replication
{
	reliable if (Role == ROLE_Authority)
		ExplodeTimer;
}

simulated function Destroyed()
{
	if (Trail != None)
		Trail.mRegen = false;

	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	local PlayerController PC;

	Super.PostBeginPlay();

	if (Level.NetMode != NM_DedicatedServer)
	{
		PC = Level.GetLocalPlayerController();
		if ((PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5500)
			Trail = Spawn(class'MP5RocketTrailSmoke', self,, Location, Rotation);
	}

	if (Role == ROLE_Authority)
	{
		Velocity = Speed * Vector(Rotation);
		RandSpin(25000);
		bCanHitOwner = false;
		if (Instigator.HeadVolume.bWaterVolume)
		{
			bHitWater = true;
			Velocity = 0.6*Velocity;
		}
	}
}

simulated function PostNetBeginPlay()
{
	if (Physics == PHYS_None)
	{
		SetTimer(ExplodeTimer, false);
		bTimerSet = true;
	}
}

simulated function Timer()
{
	Explode(Location, vect(0,0,1));
}

simulated function Landed(vector HitNormal)
{
	HitWall(HitNormal, None);
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	if (!Other.bWorldGeometry && (Other != Instigator || bCanHitOwner))
		Explode(HitLocation, Normal(HitLocation-Other.Location));
}

simulated function HitWall(vector HitNormal, Actor Wall)
{
	local Vector VNorm;
	local PlayerController PC;

	if ((Pawn(Wall) != None) || (GameObjective(Wall) != None))
	{
		Explode(Location, HitNormal);
		return;
	}

	if (!bTimerSet)
	{
		SetTimer(ExplodeTimer, false);
		bTimerSet = true;
	}

	// Reflect off Wall w/damping
	VNorm = (Velocity dot HitNormal) * HitNormal;
	Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

	RandSpin(100000);
	DesiredRotation.Roll = 0;
	RotationRate.Roll = 0;
	Speed = VSize(Velocity);

	if (Speed < 20)
	{
		bBounce = false;
		PrePivot.Z = -1.5;
		SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
		if (Trail != None)
			Trail.mRegen = false;
	}
	else
	{
		if ((Level.NetMode != NM_DedicatedServer) && (Speed > 250))
		{
			PlaySound(ImpactSound, SLOT_Misc);
		}
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}

		if (!Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false))
		{
			PC = Level.GetLocalPlayerController();
			if ((PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000)
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
			LastSparkTime = Level.TimeSeconds;
		}
	}
}

simulated function BlowUp(vector HitLocation)
{
	DelayedHurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	if (Role == ROLE_Authority)
		MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	BlowUp(HitLocation);
	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
	if (EffectIsRelevant(Location, false))
	{
		Spawn(class'ShockComboCore',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(class'ShockExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(class'SmallRedeemerExplosion',,, HitLocation, rotator(vect(0,0,1)));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
	Destroy();
}

defaultproperties
{
     ExplodeTimer=2.000000
     DampenFactor=0.500000
     DampenFactorParallel=0.800000
     HitEffectClass=Class'XEffects.ChildBlueSparks'
     Speed=1000.000000
     MaxSpeed=1500.000000
     TossZ=0.000000
     Damage=100.000000
     DamageRadius=300.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'tk_ZenCoders.DamTypeMP5Grenade'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.GrenadeMesh'
     Physics=PHYS_Falling
     DrawScale=3.000000
     Skins(0)=Texture'WeaponSkins.AmmoPickups.BioRiflePickup'
     AmbientGlow=100
     FluidSurfaceShootStrengthMod=3.000000
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}