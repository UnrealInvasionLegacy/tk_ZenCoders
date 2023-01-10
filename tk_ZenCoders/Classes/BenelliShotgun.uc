class BenelliShotgun extends tk_Weapon
	config(TKWeaponsClient);

var int clientInventoryGroup;
var(FirstPerson) float CenteredOffsetZ;
var(FirstPerson) float CenteredOffsetX;
var int IconOffsetY[9];

var() config bool bKick;
var bool bkickRep;

replication
{
	reliable if (Role == ROLE_Authority)
		clientInventoryGroup;
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer|| Level.NetMode == NM_ListenServer)
	{
		clientInventoryGroup = InventoryGroup;
	}

	if (Level.NetMode == NM_client)
	{
		InventoryGroup = clientInventoryGroup;
	}

	IconCoords.Y2 = (default.IconCoords.Y2 + (IconOffsetY[InventoryGroup-1] + 10));

	Super.PostNetBeginPlay();
}

simulated singular function ClientStopFire(int Mode)
{
	if (!HasAmmo())
		DoAutoSwitch();

	Super.ClientStopFire(Mode);
}

simulated function bool HasAmmo()
{
	return ( (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
		|| (Ammo[1] != None && FireMode[1] != None && Ammo[1].AmmoAmount >= FireMode[1].AmmoPerFire) );
}

simulated function class<Ammunition> GetAmmoClass(int mode)
{
	local float MaxAmmoPrimary, CurAmmoPrimary;

 	MaxAmmoPrimary = 1;
    	CurAmmoPrimary = 1;
	GetAmmoCount(MaxAmmoPrimary, CurAmmoPrimary);

	if ((CurAmmoPrimary/MaxAmmoPrimary) < 0.15)
		return None;

	return AmmoClass[mode];
}

simulated function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(p);
	if (ThirdPersonActor != None)
	{
		ThirdPersonActor.Destroy();
		ThirdPersonActor = None;
	}
	P.AmbientSound = None;
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if (B == None)
		return AIRating;

	if (B.Enemy == None)
	{
		if ((B.Target != None) && VSize(B.Target.Location - B.Pawn.Location) > 8000)
			return 0.9;
		return AIRating;
	}

	if (!B.ProficientWithWeapon())
		return AIRating;

	if (B.Stopped())
	{
		if (!B.EnemyVisible() && (VSize(B.Enemy.Location - Instigator.Location) < 5000))
			return (AIRating + 0.5);
		return (AIRating + 0.3);
	}
	else if (VSize(B.Enemy.Location - Instigator.Location) > 1600)
	{
		return (AIRating + 0.1);
	}
	else if (B.Enemy.Location.Z > B.Location.Z + 200)
	{
		return (AIRating + 0.15);
	}

	return AIRating;
}

function byte BestMode()
{
	local float EnemyDist, MaxDist;
	local bot B;

	B = Bot(Instigator.Controller);
	if ((B == None) || (B.Enemy == None))
		return 0;

	if (B.IsShootingObjective())
		return 0;

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if (B.Skill > 5)
		MaxDist = 4 * class'BenelliChunk'.default.Speed;
	else
		MaxDist = 3 * class'BenelliChunk'.default.Speed;

	if ((EnemyDist > MaxDist) || (EnemyDist < 150))
		return 0;

	if ((EnemyDist > 2500) && (FRand() < 0.5))
		return 0;

	if (FRand() < 0.7)
		return 0;

	return 1;
}

function float SuggestAttackStyle()
{
	if ((AIController(Instigator.Controller) != None) && (AIController(Instigator.Controller).Skill < 3))
		return 0.4;

	return 0.8;
}

function float SuggestDefenseStyle()
{
	return -0.4;
}

defaultproperties
{
     CenteredOffsetZ=-5.500000
     CenteredOffsetX=5.000000
     IconOffsetY(0)=-12
     IconOffsetY(1)=-8
     IconOffsetY(3)=-12
     IconOffsetY(4)=-4
     IconOffsetY(5)=-18
     IconOffsetY(6)=-10
     IconOffsetY(7)=-13
     IconOffsetY(8)=-15
     FireModeClass(0)=Class'tk_ZenCoders.BenelliFire'
     FireModeClass(1)=Class'tk_ZenCoders.BenelliAltFire'
     PutDownAnim="PutDown"
     IdleAnimRate=0.050000
     SelectAnimRate=1.300000
     SelectSound=Sound'WeaponSounds.AssaultRifle.SwitchToAssaultRifle'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.750000
     CurrentRating=0.400000
     bNoAmmoInstances=False
     EffectOffset=(X=27.000000,Y=3.000000,Z=4.000000)
     DisplayFOV=70.000000
     Priority=23
     HudColor=(B=192,G=128)
     SmallViewOffset=(X=18.000000,Y=8.700000,Z=-8.000000)
     SmallEffectOffset=(X=27.000000,Y=3.000000,Z=4.000000)
     CenteredOffsetY=1.500000
     CenteredRoll=0
     CenteredYaw=-100
     CustomCrosshair=2
     CustomCrossHairColor=(B=0,G=128)
     CustomCrossHairScale=0.500000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Circle1"
     InventoryGroup=7
     GroupOffset=2
     PickupClass=Class'tk_ZenCoders.BenelliPickup'
     PlayerViewOffset=(X=14.000000,Y=7.700000,Z=-6.000000)
     PlayerViewPivot=(Pitch=700)
     BobDamping=1.700000
     AttachmentClass=Class'tk_ZenCoders.BenelliAttachment'
     IconMaterial=Texture'tk_ZenCoders.Zen.ZenIcons'
     IconCoords=(X1=14,Y1=12,X2=88,Y2=44)
     ItemName="Benelli Shotgun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'tk_ZenCoders.Zen.Benelli_1st'
     DrawScale=1.200000
     UV2Texture=Shader'XGameShaders.WeaponShaders.WeaponEnvShader'
}