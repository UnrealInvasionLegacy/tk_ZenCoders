class MP5Gun extends Weapon
	config(TKWeaponsClient);

var int clientInventoryGroup;
var(FirstPerson) float CenteredOffsetZ;
var(FirstPerson) float CenteredOffsetX;
var int IconOffsetY[9];

replication
{
	reliable if (Role == Role_Authority)
		clientInventoryGroup;
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer|| Level.NetMode == NM_ListenServer)
		clientInventoryGroup = InventoryGroup;

	if (Level.NetMode == NM_Client)
	{
		InventoryGroup = clientInventoryGroup;
	}

	IconCoords.Y2 = (default.IconCoords.Y2 + (IconOffsetY[InventoryGroup-1] + 8));

	if ((Role < ROLE_Authority) && (Instigator != None) && (Instigator.Controller != None) && (Instigator.Weapon != self) && (Instigator.PendingWeapon != self))
		Instigator.Controller.ClientSwitchToBestWeapon();

	Super.PostNetBeginPlay();
}

simulated function DetachFromPawn(Pawn P)
{
	MP5AltFire(FireMode[1]).ReturnToIdle();
	Super.DetachFromPawn(P);
}

function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ((B != None) && (B.Enemy != None))
	{
		if (((FRand() < 0.1) || !B.EnemyVisible()) && (AmmoAmount(1) >= FireMode[1].AmmoPerFire))
			return 1;
	}

	if (AmmoAmount(0) >= FireMode[0].AmmoPerFire)
		return 0;

	return 1;
}

simulated singular function ClientStopFire(int Mode)
{
	if (!HasAmmo())
		DoAutoSwitch();

	Super.ClientStopFire(Mode);
}

simulated singular function ClientStartFire(int Mode)
{
	if (!HasAmmo())
	   DoAutoSwitch();

	Super.ClientStartFire(Mode);
}

simulated function DrawWeaponInfo(Canvas Canvas)
{
	NewDrawWeaponInfo(Canvas, 0.705*Canvas.ClipY);
}

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
	local int i, Count;
	local float ScaleFactor;

	ScaleFactor = 99 * Canvas.ClipX/3200;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = class'HUD'.default.WhiteColor;

	Count = Min(8, AmmoAmount(1));
	for(i = 0; i < Count; i++)
	{
		Canvas.SetPos(Canvas.ClipX - (0.5*i+1) * ScaleFactor, YPos);
		Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 174, 259, 46, 45);
	}

	if (AmmoAmount(1) > 8)
	{
		Count = Min(16,AmmoAmount(1));
		for(i = 8; i < Count; i++)
		{
			Canvas.SetPos(Canvas.ClipX - (0.5*(i-8)+1) * ScaleFactor, YPos - ScaleFactor);
			Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 174, 259, 46, 45);
		}
	}
}

simulated function float ChargeBar()
{
	if (FireMode[1].bIsFiring)
		return FMin(1, FireMode[1].HoldTime/MP5AltFire(FireMode[1]).mHoldClampMax);

	return 0;
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ((B == None) || (B.Enemy == None))
	   return AIRating;

	if (B.Enemy == None)
	{
		if ((B.Target != None) && VSize(B.Target.Location - B.Pawn.Location) > 8000)
			return 0.78;
		return AIRating;
	}

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location), 0, 1000));
}

defaultproperties
{
     CenteredOffsetZ=-5.500000
     CenteredOffsetX=9.000000
     IconOffsetY(0)=-12
     IconOffsetY(1)=-8
     IconOffsetY(3)=-12
     IconOffsetY(4)=-4
     IconOffsetY(5)=-18
     IconOffsetY(6)=-10
     IconOffsetY(7)=-13
     IconOffsetY(8)=-15
     FireModeClass(0)=Class'tk_ZenCoders.MP5Fire'
     FireModeClass(1)=Class'tk_ZenCoders.MP5AltFire'
     SelectAnim="AltFire"
     PutDownAnim="PutDown"
     IdleAnimRate=0.000000
     SelectSound=Sound'WeaponSounds.AssaultRifle.SwitchToAssaultRifle'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.700000
     CurrentRating=0.400000
     bShowChargingBar=True
     Description="Inexpensive and easily produced, the MP5 provides a lightweight 5.56mm combat solution that is most effective against unarmored foes. With low-to-moderate armor penetration capabilities, this rifle is best suited to a role as a light support weapon.|The optional M355 dual-fire Rocket-Propelled Grenade Launcher provides the punch that makes this weapon effective against heavily armored enemies."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     MessageNoAmmo=" is out of ammunition"
     DisplayFOV=70.000000
     Priority=3
     HudColor=(B=128,R=128)
     SmallViewOffset=(X=10.000000,Y=10.000000,Z=-6.000000)
     CenteredOffsetY=2.000000
     CenteredYaw=-200
     CustomCrosshair=4
     CustomCrossHairColor=(B=128,R=128)
     CustomCrossHairScale=0.750000
     CustomCrossHairTextureName="ONSInterface-TX.MineLayerReticle"
     InventoryGroup=2
     GroupOffset=2
     PickupClass=Class'tk_ZenCoders.MP5Pickup'
     PlayerViewOffset=(X=5.000000,Y=8.000000,Z=-4.000000)
     PlayerViewPivot=(Pitch=400)
     BobDamping=1.700000
     AttachmentClass=Class'tk_ZenCoders.MP5Attachment'
     IconMaterial=Texture'tk_ZenCoders.Zen.ZenIcons'
     IconCoords=(X1=112,Y1=9,X2=192,Y2=49)
     ItemName="ZenCoders MP5"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'tk_ZenCoders.Zen.mp5_1st'
     UV2Texture=Shader'XGameShaders.WeaponShaders.WeaponEnvShader'
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}