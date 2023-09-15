using Vector2 = System.Numerics.Vector2;
using Foliage.Math;
using System.Collections.ObjectModel;
using System.Collections.Specialized;

namespace Foliage.Board.Base;

public class BodyData
{
    public event NotifyCollectionChangedEventHandler PositionsChanged;
    public ReadOnlyDictionary<Vector2, IFunctional> Tiles { get; }
    public void AssignBody(Vector2 position, IFunctional functionality)
    {

    }
    public void RemoveBody(Vector2 position)
    {
        
    }
    public Vector2 Offset { get => _tileOffset; }
    public void Move(Vector2 distance)
    {
        _tileOffset += distance;
        while (_tileOffset.X < TileOffsetMin)
            ShiftTile(Directions.Right);
        while (_tileOffset.Y < TileOffsetMin)
            ShiftTile(Directions.Down);
        while (_tileOffset.X >= TileOffsetMax)
            ShiftTile(Directions.Left);
        while (_tileOffset.Y >= TileOffsetMax)
            ShiftTile(Directions.Up);
    }
    private void ShiftTile(Directions direction)
    {
        Vector2 shift = direction.DirectionToVector2();
        _tileOffset += shift;
        _locationOffset -= shift;
        // trigger the event here
    }
    private Vector2 _tileOffset;
    private Vector2 _locationOffset;
    private const float TileOffsetMargin = 0.1f;
    private const float TileOffsetMin = 0.0f - TileOffsetMargin;
    private const float TileOffsetMax = 1.0f + TileOffsetMargin;
}
