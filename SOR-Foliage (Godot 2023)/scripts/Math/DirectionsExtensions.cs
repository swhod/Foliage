using Vector2 = System.Numerics.Vector2;

namespace Foliage.Math;

public static class DirectionsExtensions
{
    public static Vector2 DirectionsToVector2(this Directions direction)
        => ((direction & Directions.Right) == Directions.Right?  Vector2.UnitX: Vector2.Zero) +
           ((direction & Directions.Down ) == Directions.Down ?  Vector2.UnitY: Vector2.Zero) +
           ((direction & Directions.Left ) == Directions.Left ? -Vector2.UnitX: Vector2.Zero) +
           ((direction & Directions.Up   ) == Directions.Up   ? -Vector2.UnitY: Vector2.Zero);

    public static Directions Reverse(this Directions direction)
        => (Directions)((int)direction % 4 << 2 + (int)direction >> 2);
}
