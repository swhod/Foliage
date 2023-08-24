namespace Foliage.Math;

/// <summary>
/// Stores an integer code about information on four directions.
/// </summary>
public struct Compass
{
    private int _code;
    public int Code
    {
        get => _code;
        set { _code = value & CodeFull; }
    }

    public Compass()
        => _code = CodeNone;
    public Compass(int pad)
        => _code = pad & CodeFull;
    public Compass(bool right, bool up, bool left, bool down)
        => _code = (right? CodeOnlyRight: CodeNone) |
                  (up? CodeOnlyUp: CodeNone) |
                  (left? CodeOnlyLeft: CodeNone) |
                  (down? CodeOnlyDown: CodeNone);

    public bool Has(Direction direction)
        => (_code & (int)direction) != 0;
    public void Add(Direction direction)
        => _code |= (int)direction;
    public void Remove(Direction direction)
        => _code &= ~(int)direction;
    public void Toggle(Direction direction)
        => _code ^= (int)direction;
    
    public static Compass operator ~(Compass a)
        => new(~a._code);
    public static Compass operator &(Compass a, Compass b)
        => new(a._code & b._code);
    public static Compass operator |(Compass a, Compass b)
        => new(a._code | b._code);
    public static Compass operator ^(Compass a, Compass b)
        => new(a._code ^ b._code);
    public static bool operator ==(Compass a, Compass b)
        => a._code == b._code;
    public static bool operator !=(Compass a, Compass b)
        => a._code != b._code;

    public override bool Equals(System.Object obj)
    {
        if (obj == null || !(obj is Compass))
            return false;
        else 
            return this == (Compass)obj;
    }
    public override int GetHashCode()
        => _code.GetHashCode();
    public override string ToString()
        => _code.ToString();
    
    public const int CodeNone = 0b_0000;
    public const int CodeFull = 0b_1111;
    public const int CodeOnlyRight = (int)Direction.Right;
    public const int CodeOnlyUp = (int)Direction.Up;
    public const int CodeOnlyLeft = (int)Direction.Left;
    public const int CodeOnlyDown = (int)Direction.Down;
    public static readonly Compass None = new(CodeNone);
    public static readonly Compass Full = new(CodeFull);
    public static readonly Compass OnlyRight = new(CodeOnlyRight);
    public static readonly Compass OnlyUp = new(CodeOnlyUp);
    public static readonly Compass OnlyLeft = new(CodeOnlyLeft);
    public static readonly Compass OnlyDown = new(CodeOnlyDown);
}
