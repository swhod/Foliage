using Vector2 = System.Numerics.Vector2;

namespace Foliage.Math;

public static class DirectionsExtensions
{
    public static Vector2 DirectionToVector2(this Directions direction)
    {
        switch(direction)
        {
            case Directions.Right: return  Vector2.UnitX;
            case Directions.Down : return  Vector2.UnitY;
            case Directions.Left : return -Vector2.UnitX;
            case Directions.Up   : return -Vector2.UnitY;
            default              : return  Vector2.Zero ;
        }
    }
    public static Directions Reverse(this Directions direction)
        => (Directions)((int)direction % 4 << 2 + (int)direction >> 2);
}
