namespace Foliage.Math;

/// <summary>
/// A 2D axis-aligned bounding box represented by two points.
/// </summary>
public struct PlanarBox
{
    public float X1 { get; set; }
    public float Y1 { get; set; }
    public float X2 { get; set; }
    public float Y2 { get; set; }
    public PlanarVector Point1
    {
        get => new(X1, Y1);
        set { (X1, Y1) = (value.X, value.Y); }
    }
    public PlanarVector Point2
    {
        get => new(X2, Y2);
        set { (X2, Y2) = (value.X, value.Y); }
    }
    public float Left => System.Math.Min(X1, X2);
    public float Right => System.Math.Max(X1, X2);
    public float Top => System.Math.Min(Y1, Y2);
    public float Bottom => System.Math.Max(Y1, Y2);
    public float Width => System.Math.Abs(X2 - X1);
    public float Height => System.Math.Abs(Y2 - Y1);
    public PlanarVector Location => new(Left, Top);
    public PlanarVector Size => new(Width, Height);
    public float Area
        => X2 >= X1 && Y2 >= Y1? Width * Height: -Width * Height;

    public PlanarBox()
        => (X1, Y1, X2, Y2) = (0, 0, 0, 0);
    public PlanarBox(PlanarVector point1, PlanarVector point2)
        => (X1, Y1, X2, Y2) = (point1.X, point1.Y, point2.X, point2.Y);
    public PlanarBox(float x1, float y1, float x2, float y2)
        => (X1, Y1, X2, Y2) = (x1, y1, x2, y2);

    public static implicit operator PlanarBox(Godot.Rect2 rectangle)
        => new(rectangle.Position, rectangle.End);
    public static implicit operator PlanarBox(System.Drawing.RectangleF rectangle)
        => new(rectangle.Left, rectangle.Top, rectangle.Right, rectangle.Bottom);
    public static implicit operator Godot.Rect2(PlanarBox box)
        => new(box.Location, box.Size);
    public static implicit operator System.Drawing.RectangleF(PlanarBox box)
        => new(box.Left, box.Top, box.Right, box.Bottom);
    
    public static bool operator true(PlanarBox box)
        => box.X2 >= box.X1 && box.Y2 >= box.Y1;
    public static bool operator false(PlanarBox box)
        => box.X2 < box.X1 || box.Y2 < box.Y1;
    public static PlanarBox operator &(PlanarBox left, PlanarBox right)
        => new(System.Math.Min(left.Left, right.Left),
               System.Math.Min(left.Top, right.Top),
               System.Math.Max(left.Right, right.Right),
               System.Math.Max(left.Bottom, right.Bottom));
    public static PlanarBox operator |(PlanarBox left, PlanarBox right)
        => new(System.Math.Max(left.Left, right.Left),
               System.Math.Max(left.Top, right.Top),
               System.Math.Min(left.Right, right.Right),
               System.Math.Min(left.Bottom, right.Bottom));
    public static PlanarBox operator +(PlanarBox box, PlanarVector vector)
        => new(box.Point1 + vector, box.Point2 + vector);
    public static PlanarBox operator -(PlanarBox box, PlanarVector vector)
        => new(box.Point1 + vector, box.Point2 - vector);
    public static bool operator ==(PlanarBox left, PlanarBox right)
        => left.Location == right.Location && left.Size == right.Size;
    public static bool operator !=(PlanarBox left, PlanarBox right)
        => left.Location != right.Location || left.Size != right.Size;
    
    public override bool Equals(System.Object obj)
    {
        if (obj == null || !(obj is PlanarBox))
            return false;
        else 
            return this == (PlanarBox)obj;
    }
    public override int GetHashCode()
        => Algorithm.ShiftAndWrap(Location.GetHashCode(), 5) ^ Size.GetHashCode();
}
