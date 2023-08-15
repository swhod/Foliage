namespace Foliage.Math;

public static class DirectionPad
{
    public const int None = 0b_0000;
    public const int Full = 0b_1111;
        
    public static bool HasDirection(int code, Direction dir)
        => (code & (int)dir) != 0;
    
    public static PlanarVector DirectionToVector(Direction dir)
    {
        switch(dir)
        {
            case Direction.Right:
                return PlanarVector.Right;
            case Direction.Up:
                return PlanarVector.Up;
            case Direction.Left:
                return PlanarVector.Left;
            case Direction.Down:
                return PlanarVector.Down;
            default:
                return PlanarVector.Zero;
        }
    }
}
