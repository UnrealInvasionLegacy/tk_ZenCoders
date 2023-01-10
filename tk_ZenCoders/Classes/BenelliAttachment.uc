class BenelliAttachment extends AssaultAttachment
      placeable;

function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal)
{
	SpawnHitCount++;
	mHitLocation = HitLocation;
	mHitActor = HitActor;
	mHitNormal = HitNormal;
}

simulated event ThirdPersonEffects()
{
	local PlayerController PC;

	if ((Level.NetMode == NM_DedicatedServer) || (Instigator == None))
		return;
		
	if (FlashCount > 0)
	{
		PC = Level.GetLocalPlayerController();
		if (OldSpawnHitCount != SpawnHitCount)
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();

			PC = Level.GetLocalPlayerController();
			if ((Instigator.Controller == PC) || (VSize(PC.ViewTarget.Location - mHitLocation) < 2000))
			{
				if (FiringMode == 0)
				{
					Spawn(class'ONSGrenadeExplosionEffect',,, mHitLocation, Rotator(mHitNormal));
					Spawn(class'XEffects.ExploWallHit',,, mHitLocation, Rotator(mHitNormal));
				}
				else
				{
					Spawn(class'XEffects.ExploWallHit',,, mHitLocation, Rotator(mHitNormal));
				}
				CheckForSplash();
			}
		}

		WeaponLight();
	}

	Super.ThirdPersonEffects();
}

defaultproperties
{
     bRapidFire=False
     Mesh=SkeletalMesh'tk_ZenCoders.Zen.Benelli_3rd'
     RelativeLocation=(X=0.000000,Y=0.000000)
     RelativeRotation=(Pitch=0)
     DrawScale=1.400000
}