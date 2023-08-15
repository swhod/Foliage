using Foliage.Math;
using System.Collections.Generic;

namespace Foliage.BoardElement;

/// <summary>
/// The common interface of tiled objects.
/// </summary>
public interface ITiled
{
    /// <summary>
    /// The dictionary mapping all coordinates of occupied tiles
    /// to certain tiled objects.
    /// </summary>
    Dictionary<PlanarVector, IElement> Tiles { get; set; }

    /// <summary>
    /// The offset from the tile grid.
    /// </summary>
    PlanarVector Offset { get; set; }
}
