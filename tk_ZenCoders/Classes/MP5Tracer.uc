class MP5Tracer extends Emitter;

simulated function SpawnParticle(int Amount)
{
	local PlayerController PC;
	local vector Dir, LineDir, LinePos, RealLocation;

	Super.SpawnParticle(Amount);

	if ((Instigator == None) || Instigator.IsFirstPerson())
		return;

	PC = Level.GetLocalPlayerController();
	if ((PC != None) && (PC.Pawn != None))
	{
		Dir.X = Emitters[0].StartVelocityRange.X.Min;
		Dir.Y = Emitters[0].StartVelocityRange.Y.Min;
		Dir.Z = Emitters[0].StartVelocityRange.Z.Min;
		Dir = Normal(Dir);
		LinePos = (Location + (Dir dot (PC.Pawn.Location - Location)) * Dir);
		LineDir = PC.Pawn.Location - LinePos;
		if (VSize(LineDir) < 150)
		{
			RealLocation = Location;
			SetLocation(LinePos);
			if (FRand() < 0.5)
				PlaySound(sound'Impact3Snd',,,,80);
			else
				PlaySound(sound'Impact7Snd',,,,80);
			SetLocation(RealLocation);
		}
	}
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter13
         UseDirectionAs=PTDU_Right
         UseColorScale=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseAbsoluteTimeForSizeScale=True
         UseRegularSizeScale=False
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         ExtentMultiplier=(X=0.200000)
         ColorScale(0)=(Color=(B=250,G=220,R=190))
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=233,G=140,R=65))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=236,G=115,R=75))
         ColorScale(3)=(RelativeTime=1.000000)
         ColorMultiplierRange=(Y=(Min=0.800000,Max=0.800000),Z=(Min=0.500000,Max=0.500000))
         MaxParticles=100
         SizeScale(1)=(RelativeTime=0.030000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=7.000000,Max=7.000000))
         ScaleSizeByVelocityMultiplier=(X=0.002000)
         Texture=Texture'AW-2004Particles.Weapons.TracerShot'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(X=(Min=10000.000000,Max=10000.000000))
     End Object
     Emitters(0)=SpriteEmitter'tk_ZenCoders.MP5Tracer.SpriteEmitter13'

     bNoDelete=False
     bHardAttach=True
}