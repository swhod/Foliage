namespace Foliage.Math;

/// <summary>
/// Enumerates four basic directions.
/// </summary>
[System.Flags]
public enum Directions: int
{
    None    = 0,
    Right   = 0b_0001,
    Down    = 0b_0010,
    Left    = 0b_0100,
    Up      = 0b_1000,
}
