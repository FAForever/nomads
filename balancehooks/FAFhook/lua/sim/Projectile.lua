do


local oldProjectile = Projectile

Projectile = Class(oldProjectile) {
    CanDoInitialDamage = false,  # used to prevent doing initialdamage twice in FAF games.
}


end