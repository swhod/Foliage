using Vector2 = System.Numerics.Vector2;
using System.Collections.Generic;

namespace Foliage.BoardElement;

public interface IStructural
{
    /// <summary>
    /// Maps all coordinates of occupied tiles to functionalities.
    /// </summary>
    Dictionary<Vector2, string> Tiles { get; set; }

    /// <summary>
    /// Represents the offset from the tile grid.
    /// </summary>
    Vector2 Offset { get; set; }

    /// <summary>
    /// Holds all the acting effects.
    /// </summary>
    List<Behaviour> Effects { get; set; }
}
