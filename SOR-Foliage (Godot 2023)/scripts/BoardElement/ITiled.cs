using Vector2 = System.Numerics.Vector2;
using System.Collections.Generic;

namespace Foliage.BoardElement;

public interface ITiled<T>
{
    /// <summary>
    /// Maps all coordinates of occupied tiles to objects in given type T.
    /// </summary>
    Dictionary<Vector2, T> Tiles { get; set; }

    /// <summary>
    /// The offset from the tile grid.
    /// </summary>
    Vector2 Offset { get; set; }
}
