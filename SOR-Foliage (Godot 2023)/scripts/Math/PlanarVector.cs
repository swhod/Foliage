namespace Foliage.Math;

/// <summary>
/// A 2D vector using floating-point values.
/// </summary>
public struct PlanarVector
{
    public float X { get; set; }
    public float Y { get; set; }

    public PlanarVector() 
        => (X, Y) = (0, 0);
    public PlanarVector(float x, float y) 
        => (X, Y) = (x, y);

    public static implicit operator PlanarVector(Godot.Vector2 vector)
        => new(vector.X, vector.Y);
    public static implicit operator PlanarVector(System.Numerics.Vector2 vector)
        => new(vector.X, vector.Y);
    public static implicit operator Godot.Vector2(PlanarVector vector)
        => new(vector.X, vector.Y);
    public static implicit operator System.Numerics.Vector2(PlanarVector vector)
        => new(vector.X, vector.Y);
    
    public static PlanarVector operator +(PlanarVector vector)
        => new(+vector.X, +vector.Y);
    public static PlanarVector operator -(PlanarVector vector)
        => new(-vector.X, -vector.Y);
    public static PlanarVector operator +(PlanarVector left, PlanarVector right)
        => new(left.X + right.X, left.Y + right.Y);
    public static PlanarVector operator -(PlanarVector left, PlanarVector right)
        => new(left.X - right.X, left.Y - right.Y);
    public static PlanarVector operator *(PlanarVector left, float right)
        => new(left.X * right, left.Y * right);
    public static PlanarVector operator *(float left, PlanarVector right)
        => new(left * right.X, left * right.Y);
    public static PlanarVector operator /(PlanarVector left, float right)
        => new(left.X / right, left.Y / right);
    public static bool operator ==(PlanarVector left, PlanarVector right)
        => left.X == right.X && left.Y == right.Y;
    public static bool operator !=(PlanarVector left, PlanarVector right)
        => left.X != right.X || left.Y != right.Y;
    public static bool operator >=(PlanarVector left, PlanarVector right)
        => (left.X > right.X) || (left.X == right.X && left.Y >= right.Y);
    public static bool operator <=(PlanarVector left, PlanarVector right)
        => (left.X < right.X) || (left.X == right.X && left.Y <= right.Y);
    public static bool operator >(PlanarVector left, PlanarVector right)
        => (left.X > right.X) || (left.X == right.X && left.Y > right.Y);
    public static bool operator <(PlanarVector left, PlanarVector right)
        => (left.X < right.X) || (left.X == right.X && left.Y < right.Y);
    
    public override bool Equals(System.Object obj)
    {
        if (obj == null || !(obj is PlanarVector))
            return false;
        else 
            return this == (PlanarVector)obj;
    }
    public override int GetHashCode()
        => Algorithm.ShiftAndWrap(X.GetHashCode(), 2) ^ Y.GetHashCode();
    
    public static readonly PlanarVector Zero = new(0, 0);
    public static readonly PlanarVector One = new(1, 1);
    public static readonly PlanarVector Right = new(1, 0);
    public static readonly PlanarVector Up = new(0, -1);
    public static readonly PlanarVector Left = new(-1, 0);
    public static readonly PlanarVector Down = new(0, 1);
}
