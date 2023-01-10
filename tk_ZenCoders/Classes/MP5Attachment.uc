class MP5Attachment extends AssaultAttachment;

var class<Emitter> mTracerClass;
var() editinline Emitter mTracer;
var float mTracerInterval;
var() float mTracerIntervalPrimary;
var() float mTracerPullback;
var() float mTracerMinDistance;
var() float mTracerSpeed;
var float mLastTracerTime;
var vector mOldHitLocation;

simulated function Destroyed()
{
	if (bDualGun)
	{
		if (Instigator != None)
		{
			Instigator.SetBoneDirection(AttachmentBone, Rotation,, 0, 0);
			Instigator.SetBoneDirection('lfarm', Rotation,, 0, 0);
		}
	}

	if (mTracer != None)
		mTracer.Destroy();

	if (mMuzFlash3rd != None)
		mMuzFlash3rd.Destroy();

	if (mMuzFlash3rdAlt != None)
		mMuzFlash3rdAlt.Destroy();

	Super.Destroyed();
}

simulated function vector GetTracerStart()
{
	local Pawn p;

	p = Pawn(Owner);
	if ((p != None) && p.IsFirstPerson() && p.Weapon != None)
		return p.Weapon.GetEffectStart();

	if (mMuzFlash3rd != None)
		return mMuzFlash3rd.Location;
	else
		return Location;
}

simulated function UpdateTracer()
{
	local vector SpawnLoc, SpawnDir, SpawnVel;
	local float hitDist;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	if (mTracer == None)
		mTracer = Spawn(mTracerClass);

	if (mTracer != None && Level.TimeSeconds > mLastTracerTime + mTracerInterval)
	{
		SpawnLoc = GetTracerStart();
		mTracer.SetLocation(SpawnLoc);

		hitDist = VSize(mHitLocation - SpawnLoc) - mTracerPullback;
		if (mHitLocation == mOldHitLocation)
			SpawnDir = vector(Instigator.GetViewRotation());
		else
			SpawnDir = Normal(mHitLocation - SpawnLoc);

		if (hitDist > mTracerMinDistance)
		{
			SpawnVel = SpawnDir * mTracerSpeed;

			mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
			mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
			mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
			mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;

			mTracer.Emitters[0].LifetimeRange.Min = hitDist / mTracerSpeed;
			mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;

			mTracer.SpawnParticle(1);
		}

		mLastTracerTime = Level.TimeSeconds;
	}

	mOldHitLocation = mHitLocation;
}

simulated event ThirdPersonEffects()
{
	local rotator r;
	local PlayerController PC;

	if (Level.NetMode != NM_DedicatedServer)
	{
		AimAlpha = 1;
		if (TwinGun != None)
			TwinGun.AimAlpha = 1;

		if (FiringMode == 0)
		{
			WeaponLight();
			if (OldSpawnHitCount != SpawnHitCount)
			{
				OldSpawnHitCount = SpawnHitCount;
				GetHitInfo();
				PC = Level.GetLocalPlayerController();
				if (((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000))
				{
					Spawn(class'HitEffect'.static.GetHitEffect(mHitActor, mHitLocation, mHitNormal),,, mHitLocation, Rotator(mHitNormal));
					CheckForSplash();
				}
			}

			MakeMuzzleFlash();
			if (!bDualGun && (TwinGun != None))
				TwinGun.MakeMuzzleFlash();

			mTracerInterval = mTracerIntervalPrimary;
			if (Level.bDropDetail || Level.DetailMode == DM_Low)
				mTracerInterval *= 2.0;

			UpdateTracer();
		}
		else if (FiringMode == 1 && FlashCount > 0)
		{
			WeaponLight();
			if (mMuzFlash3rdAlt == None)
			{
				mMuzFlash3rdAlt = Spawn(mMuzFlashClass);
				AttachToBone(mMuzFlash3rdAlt, 'tip2');
			}

			mMuzFlash3rdAlt.mStartParticles++;
			r.Roll = Rand(65536);
			SetBoneRotation('Bone_Flash02', r, 0, 1.f);
		}
	}

	Super.ThirdPersonEffects();
}

defaultproperties
{
     mTracerClass=Class'tk_ZenCoders.MP5Tracer'
     mTracerIntervalPrimary=0.070000
     mTracerPullback=50.000000
     mTracerSpeed=17000.000000
     Mesh=SkeletalMesh'tk_ZenCoders.Zen.mp5_3rd'
     Rotation=(Pitch=18000,Yaw=4000,Roll=400)
     RelativeLocation=(X=0.000000,Y=0.000000)
     RelativeRotation=(Pitch=0)
     DrawScale=1.400000
}