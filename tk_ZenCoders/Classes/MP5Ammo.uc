class MP5Ammo extends Ammunition
	config(TKWeaponsServer);

var config int ClientMaxAmmo;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientMaxAmmo;
}

simulated function PostNetBeginPlay()
{
	MaxAmmo = ClientMaxAmmo;
	Super.PostNetBeginPlay();
}

defaultproperties
{
     ClientMaxAmmo=180
     MaxAmmo=180
     InitialAmount=90
     PickupAmmo=45
     PickupClass=Class'tk_ZenCoders.MP5AmmoPickup'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="MP5 Rifle Ammo"
}