namespace Foliage.Math
{
    public static class DirectionPad
    {
        public const int None = 0b_0000;
        public const int Full = 0b_1111;
            
        public static bool HasDirection(int code, Direction dir)
            => (code & (int)dir) != 0;
        
        public static Vector2I DirectionToVector(Direction dir)
        {
            switch(dir)
            {
                case Direction.Right:
                    return Vector2I.Right;
                case Direction.Up:
                    return Vector2I.Up;
                case Direction.Left:
                    return Vector2I.Left;
                case Direction.Down:
                    return Vector2I.Down;
                default:
                    return Vector2I.Zero;
            }
        }
    }
}
