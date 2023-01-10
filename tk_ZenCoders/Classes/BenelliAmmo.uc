class BenelliAmmo extends Ammunition
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
     ClientMaxAmmo=48
     MaxAmmo=48
     InitialAmount=24
     PickupAmmo=12
     PickupClass=Class'tk_ZenCoders.BenelliAmmoPickup'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=458,Y1=34,X2=511,Y2=78)
     ItemName="Benelli Ammo"
}