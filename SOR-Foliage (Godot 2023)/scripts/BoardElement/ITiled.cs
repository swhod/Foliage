using Foliage.Math;
using System.Collections.Generic;

namespace Foliage.BoardElement
{
    /// <summary>
    /// The common interface of tiled objects.
    /// </summary>
    public interface ITiled
    {
        /// <summary>
        /// The dictionary mapping all coordinates of occupied tiles
        /// to certain tiled objects.
        /// </summary>
        Dictionary<Vector2I, ITiled> Area { get; set; }

        /// <summary>
        /// The non-negative offset from the tile grid.
        /// </summary>
        Vector2 Offset { get; set; }

        
    }
}
