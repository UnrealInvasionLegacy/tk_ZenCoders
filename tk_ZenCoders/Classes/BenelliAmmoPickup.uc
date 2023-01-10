class BenelliAmmoPickup extends UTAmmoPickup;

defaultproperties
{
     AmmoAmount=4
     MaxDesireability=0.320000
     InventoryType=Class'tk_ZenCoders.BenelliAmmo'
     PickupMessage="You got some Benelli Shells."
     PickupSound=Sound'PickupSounds.SniperAmmoPickup'
     PickupForce="FlakAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'tk_ZenCoders.Zen.BenelliAmmoMesh'
     PrePivot=(Z=4.000000)
     CollisionHeight=16.000000
}