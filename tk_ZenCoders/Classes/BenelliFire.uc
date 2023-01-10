class BenelliFire extends tk_InstantFire;

var() class<xEmitter> HitEmitterClass;
var(tweak) float offsetadj;
var() class<BenelliBeamFX> BeamEffectClass;
var() class<Actor> ExplosionClass;
var() class<Projector> ExplosionDecalClass;
var float DamageRadius, SplashDamage, ReloadAnimDelay;

var Vector MyDir;
var Actor MyHitActor;

simulated function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
	local BenelliBeamFX Beam;

	Super.SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

	if (Weapon != None)
	{
		Beam = Weapon.Spawn(BeamEffectClass,,, Start, Dir);
		if (ReflectNum != 0) Beam.Instigator = None;
			Beam.AimAt(HitLocation, HitNormal);
	}

	Explode(HitLocation, HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (Instigator.EffectIsRelevant(HitLocation,false))
		Spawn(ExplosionClass,,,HitLocation + HitNormal*16,rotator(HitNormal));

	BlowUp(HitLocation);
}

function BlowUp(vector HitLocation)
{
	ExtendedHurtRadius(HitLocation, MyDir, MyHitActor);
}

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
	local Actor Other;
	local bool bDoReflect;
	local xEmitter hitEmitter;
	local class<Actor> tmpHitEmitClass;
	local float tmpTraceRange;
	local vector arcEnd, EffectOffset;
	local int Damage, ReflectNum;

	MyDir = Vector(Dir);
	ReflectNum = 0;

	if (class'PlayerController'.default.bSmallWeapons)
		EffectOffset = Weapon.SmallEffectOffset;
	else
		EffectOffset = Weapon.EffectOffset;

	Weapon.GetViewAxes(X, Y, Z);
	if (Weapon.WeaponCentered())
	{
		arcEnd = (Instigator.Location + EffectOffset.Z * Z);
	}
	else if (Weapon.Hand == 0)
	{
		if (class'PlayerController'.default.bSmallWeapons)
			arcEnd = (Instigator.Location + EffectOffset.X * X);
		else
			arcEnd = (Instigator.Location + EffectOffset.X * X - 0.5 * EffectOffset.Z * Z);
	}
	else
	{
		arcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + EffectOffset.X * X + Weapon.Hand * EffectOffset.Y * Y + EffectOffset.Z * Z);
	}

	tmpHitEmitClass = HitEmitterClass;
	tmpTraceRange = TraceRange;

	while(true)
	{
		bDoReflect = false;
		X = Vector(Dir);
		End = Start + TraceRange * X;
		Other = Trace(HitLocation, HitNormal, End, Start, true);

		if (Other != None && (Other != Instigator || ReflectNum > 0))
		{
			MyHitActor = Other;
			if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
			{
				bDoReflect = false;
				HitNormal = Vect(0,0,0);
			}
			else if (!Other.bWorldGeometry)
			{
				Damage = (DamageMin + Rand(DamageMax - DamageMin)) * DamageAtten;
				Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = Vect(0,0,0);
			}
			else if (WeaponAttachment(Weapon.ThirdPersonActor) != None)
			{
				WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, HitLocation, HitNormal);
			}
		}
		else
		{
			HitLocation = End;
			HitNormal = Vect(0,0,0);
		}
		
		SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);
		if (Weapon == None)
			return;

		hitEmitter = xEmitter(Weapon.Spawn(tmpHitEmitClass,,, arcEnd, Rotator(HitNormal)));
		if (hitEmitter != None)
			hitEmitter.mSpawnVecA = HitLocation;

		if (HitScanBlockingVolume(Other) != None)
		{
			return;
		}
		else
		{
			break;
		}
	}
}

function PlayFiring()
{
	Super.PlayFiring();
	
	if (Weapon.AmmoAmount(0) > 0)
		Weapon.PlayOwnedSound(Sound'WeaponSounds.BReload9', SLOT_Misc,,,,1.1,false);

	if (Weapon.HasAnim(ReloadAnim))
		SetTimer(ReloadAnimDelay, false);
}

function Timer()
{
	if (Weapon.ClientState == WS_ReadyToFire && Instigator != None && UnrealPlayer(Weapon.Instigator.controller) != None)
	{
		if (UnrealPlayer(Weapon.Instigator.controller) != None && Level.TimeSeconds - UnrealPlayer(Weapon.Instigator.controller).LastKillTime < 1)
		{
			Weapon.PlayAnim(ReloadAnim, ReloadAnimRate, TweenTime);
			ClientPlayForceFeedback(ReloadForce);
		}
	}
}

function ExtendedHurtRadius(vector HitLocation, vector AimDir, Actor HitActor)
{
	local Actor Victims;
	local float damageScale, dist, damageAmount;
	local vector dir;

	damageAmount = RandRange(DamageMin, DamageMax) * DamageAtten;
	foreach Weapon.VisibleCollidingActors(class'Actor', Victims, DamageRadius + 200, HitLocation)
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
			Victims.TakeDamage(damageScale * damageAmount, Instigator, Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir, damageScale * Momentum * dir, DamageType);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(damageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
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
     HitEmitterClass=Class'tk_ZenCoders.BenelliBoltFX'
     BeamEffectClass=Class'tk_ZenCoders.BenelliBeamFX'
     ExplosionClass=Class'Onslaught.ONSGrenadeExplosionEffect'
     ExplosionDecalClass=Class'XEffects.RocketMark'
     DamageRadius=128.000000
     SplashDamage=55.000000
     ReloadAnimDelay=0.400000
     DamageType=Class'tk_ZenCoders.DamTypeBenelliShell'
     DamageMin=20
     DamageMax=25
     TraceRange=10240.000000
     Momentum=30000.000000
     ReloadAnim="AltFire"
     FireAnimRate=1.250000
     ReloadAnimRate=0.700000
     FireSound=Sound'tk_ZenCoders.Zen.BenelliSnd'
     FireForce="NewSniperShot"
     FireRate=1.000000
     AmmoClass=Class'tk_ZenCoders.BenelliAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=0.500000)
     ShakeRotRate=(X=-4000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-15.000000,Z=10.000000)
     ShakeOffsetRate=(X=-4000.000000,Z=4000.000000)
     ShakeOffsetTime=3.200000
     BotRefireRate=0.400000
     WarnTargetPct=0.500000
     AimError=850.000000
}