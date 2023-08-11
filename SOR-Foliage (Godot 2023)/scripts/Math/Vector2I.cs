namespace Foliage.Math
{
    public struct Vector2I
    {
        public int X { get; set; }
        public int Y { get; set; }
        public Vector2I(int x, int y) => (X, Y) = (x, y);
        public Vector2I(Vector2I vector) => (X, Y) = (vector.X, vector.Y);
        public Vector2I(Vector2 vector) => (X, Y) = ((int)vector.X, (int)vector.Y);
        
        public static explicit operator Vector2(Vector2I vector)
            => new(vector.X, vector.Y);
        public static explicit operator System.Numerics.Vector2(Vector2I vector)
            => new(vector.X, vector.Y);
        public static explicit operator Godot.Vector2(Vector2I vector)
            => new(vector.X, vector.Y);
        public static explicit operator Godot.Vector2I(Vector2I vector)
            => new(vector.X, vector.Y);

        public static Vector2I operator +(Vector2I vector)
            => new(+vector.X, +vector.Y);
        public static Vector2I operator -(Vector2I vector)
            => new(-vector.X, -vector.Y);
        public static Vector2I operator +(Vector2I left, Vector2I right)
            => new(left.X + right.X, left.Y + right.Y);
        public static Vector2I operator -(Vector2I left, Vector2I right)
            => new(left.X - right.X, left.Y - right.Y);
        public static Vector2I operator *(Vector2I left, int right)
            => new(left.X * right, left.Y * right);
        public static Vector2I operator *(int left, Vector2I right)
            => new(left * right.X, left * right.Y);
        public static Vector2I operator /(Vector2I left, int right)
            => new(left.X / right, left.Y / right);
        public static bool operator ==(Vector2I left, Vector2I right)
            => left.X == right.X && left.Y == right.Y;
        public static bool operator !=(Vector2I left, Vector2I right)
            => left.X != right.X || left.Y != right.Y;
        public static bool operator >=(Vector2I left, Vector2I right)
            => (left.X > right.X) || (left.X == right.X && left.Y >= right.Y);
        public static bool operator <=(Vector2I left, Vector2I right)
            => (left.X < right.X) || (left.X == right.X && left.Y <= right.Y);
        public static bool operator >(Vector2I left, Vector2I right)
            => (left.X > right.X) || (left.X == right.X && left.Y > right.Y);
        public static bool operator <(Vector2I left, Vector2I right)
            => (left.X < right.X) || (left.X == right.X && left.Y < right.Y);
        
        public override bool Equals(System.Object obj)
        {
            if (obj == null || !(obj is Vector2I))
                return false;
            else 
                return X == ((Vector2I)obj).X && 
                       Y == ((Vector2I)obj).Y;
        }
        public override int GetHashCode()
            => Algorithm.ShiftAndWrap(X.GetHashCode(), 2) ^ Y.GetHashCode();
        
        public static readonly Vector2I Zero = new(0, 0);
        public static readonly Vector2I One = new(1, 1);
        public static readonly Vector2I Right = new(1, 0);
        public static readonly Vector2I Up = new(0, -1);
        public static readonly Vector2I Left = new(-1, 0);
        public static readonly Vector2I Down = new(0, 1);
    }
}
