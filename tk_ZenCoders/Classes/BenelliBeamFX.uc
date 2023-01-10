class BenelliBeamFX extends ShockBeamEffect;

simulated function SpawnImpactEffects(rotator HitRot, vector EffectLoc)
{
	Spawn(class'RocketMark',,, EffectLoc, Rotator(-HitNormal));
	Spawn(class'ONSGrenadeExplosionEffect',,, EffectLoc, Rotator(-HitNormal));
	Spawn(class'RocketSmokeRing',,, EffectLoc, Rotator(HitNormal));
}

simulated function SpawnEffects()
{
	local xWeaponAttachment Attachment;

	if (Instigator != None)
	{
		if (Instigator.IsFirstPerson())
		{
			if ((Instigator.Weapon != None) && (Instigator.Weapon.Instigator == Instigator))
				SetLocation(Instigator.Weapon.GetEffectStart());
			else
				SetLocation(Instigator.Location);

			Spawn(MuzFlashClass,,, Location);
		}
		else
		{
			Attachment = xPawn(Instigator).WeaponAttachment;
			if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
				SetLocation(Attachment.GetTipLocation());
			else
				SetLocation(Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(mSpawnVecA - Instigator.Location) * 25.0);

			Spawn(MuzFlash3Class);
		}
	}

	if (EffectIsRelevant(mSpawnVecA + HitNormal*2,false) && (HitNormal != Vect(0,0,0)))
		SpawnImpactEffects(Rotator(HitNormal),mSpawnVecA + HitNormal*2);
}

defaultproperties
{
     CoilClass=None
     MuzFlashClass=None
     MuzFlash3Class=None
     mSizeRange(0)=18.000000
     mSizeRange(1)=36.000000
     mColorRange(0)=(B=0)
     mColorRange(1)=(B=0)
}