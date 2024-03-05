using System.Numerics;
using System.Collections.Generic;
using System.Collections.Immutable;
using static Directions;

public static class DirectionsExtensions
{
    public static readonly ImmutableArray<Directions> BasicDirections
        = new() {Right, Down, Left, Up};
    public static readonly ImmutableArray<Vector2> BasicVector2s
        = new() {Vector2.UnitX, Vector2.UnitY, -Vector2.UnitX, -Vector2.UnitY};
    public static readonly ImmutableArray<int> BasicRotators
        = new() {0, 1, 2, 3};
    public const float RotationUnit = 90;

    public static bool Has(this Directions d1, Directions d2)
        => (d1 & d2) == d2;
    
    public static Vector2 ToVector2(this Directions d)
    {
        for(int i = 0; i < 4; i++)
            if (d.Has(BasicDirections[i]))
                return BasicVector2s[i];
        return Vector2.Zero;
    }
    
    public static float ToRotation(this Directions d)
    {
        for(int i = 0; i < 4; i++)
            if (d.Has(BasicDirections[i]))
                return BasicRotators[i] * RotationUnit;
        return 0;
    }
    
    public static List<Vector2> ToVector2List(this Directions d)
    {
        List<Vector2> list = new();
        for(int i = 0; i < 4; i++)
            if (d.Has(BasicDirections[i])) 
                list.Add(BasicVector2s[i]);
        return list;
    }
    
    public static List<float> ToRotationList(this Directions d)
    {
        List<float> list = new();
        for(int i = 0; i < 4; i++)
            if (d.Has(BasicDirections[i])) 
                list.Add(BasicRotators[i] * RotationUnit);
        return list;
    }
}