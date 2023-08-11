namespace Foliage.Math
{
    public struct Vector2
    {
        public float X { get; set; }
        public float Y { get; set; }
        public Vector2(float x, float y) => (X, Y) = (x, y);
        public Vector2(Vector2 vector) => (X, Y) = (vector.X, vector.Y);
        public Vector2(Vector2I vector) => (X, Y) = (vector.X, vector.Y);

        public static explicit operator Vector2I(Vector2 vector) 
            => new((int)vector.X, (int)vector.Y);
        public static explicit operator System.Numerics.Vector2(Vector2 vector)
            => new(vector.X, vector.Y);
        public static explicit operator Godot.Vector2(Vector2 vector)
            => new(vector.X, vector.Y);
        public static explicit operator Godot.Vector2I(Vector2 vector)
            => new((int)vector.X, (int)vector.Y);

        public static Vector2 operator +(Vector2 vector)
            => new(+vector.X, +vector.Y);
        public static Vector2 operator -(Vector2 vector)
            => new(-vector.X, -vector.Y);
        public static Vector2 operator +(Vector2 left, Vector2 right)
            => new(left.X + right.X, left.Y + right.Y);
        public static Vector2 operator -(Vector2 left, Vector2 right)
            => new(left.X - right.X, left.Y - right.Y);
        public static Vector2 operator *(Vector2 left, float right)
            => new(left.X * right, left.Y * right);
        public static Vector2 operator *(float left, Vector2 right)
            => new(left * right.X, left * right.Y);
        public static Vector2 operator /(Vector2 left, float right)
            => new(left.X / right, left.Y / right);
        public static bool operator ==(Vector2 left, Vector2 right)
            => left.X == right.X && left.Y == right.Y;
        public static bool operator !=(Vector2 left, Vector2 right)
            => left.X != right.X || left.Y != right.Y;
        public static bool operator >=(Vector2 left, Vector2 right)
            => (left.X > right.X) || (left.X == right.X && left.Y >= right.Y);
        public static bool operator <=(Vector2 left, Vector2 right)
            => (left.X < right.X) || (left.X == right.X && left.Y <= right.Y);
        public static bool operator >(Vector2 left, Vector2 right)
            => (left.X > right.X) || (left.X == right.X && left.Y > right.Y);
        public static bool operator <(Vector2 left, Vector2 right)
            => (left.X < right.X) || (left.X == right.X && left.Y < right.Y);
        
        public override bool Equals(System.Object obj)
        {
            if (obj == null || !(obj is Vector2))
                return false;
            else 
                return X == ((Vector2)obj).X && 
                       Y == ((Vector2)obj).Y;
        }
        public override int GetHashCode()
            => Algorithm.ShiftAndWrap(X.GetHashCode(), 2) ^ Y.GetHashCode();
        
        public static readonly Vector2 Zero = new(0, 0);
        public static readonly Vector2 One = new(1, 1);
        public static readonly Vector2 Right = new(1, 0);
        public static readonly Vector2 Up = new(0, -1);
        public static readonly Vector2 Left = new(-1, 0);
        public static readonly Vector2 Down = new(0, 1);
    }
}
