class MP5RocketExplosion extends RocketExplosion;

simulated function PostBeginPlay()
{
	local PlayerController PC;

	PC = Level.GetLocalPlayerController();
	if ((PC != None) && ((PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 5000))) 
	{
		LightType = LT_None;
		bDynamicLight = false;
	}
	else 
	{
		Spawn(class'tk_ZenCoders.MP5RocketSmokeRing');
		if (Level.bDropDetail)
			LightRadius = 7;	
	}
}

defaultproperties
{
     mSizeRange(0)=80.000000
     mSizeRange(1)=160.000000
     mColorRange(0)=(G=128,R=160)
     mColorRange(1)=(G=128,R=160)
     LightHue=140
}