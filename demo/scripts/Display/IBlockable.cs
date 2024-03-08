using System.Collections.Generic;
using System;

public interface IBlockable
{
    event EventHandler<BlockMarker> BlockMarkerAdded;
    event EventHandler<BlockMarker> BlockMarkerRemoved;
    IReadOnlyList<BlockMarker> BlockMarkers { get; }
}