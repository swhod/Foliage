using Vector2 = System.Numerics.Vector2;
using Foliage.Math;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.Linq;

namespace Foliage.Board.Base;

public class BodyData
{
    /// <summary>
    /// Collects all the positions.
    /// </summary>
    public IReadOnlyCollection<Vector2> Positions => _positions;
    /// <summary>
    /// Represents the offset from aligned with tile grid.
    /// </summary>
    public Vector2 Offset => _offset;
    /// <summary>
    /// Represents the board linked with this BodyData.
    /// </summary>
    public BoardData Board => _board;

    public event NotifyCollectionChangedEventHandler PositionsChanged
    {
        add => _positions.CollectionChanged += value;
        remove => _positions.CollectionChanged -= value;
    }

    public void Add(Vector2 position)
        => _positions.Add(Floor(position));
    public void Remove(Vector2 position)
        => _positions.Remove(Floor(position));
    public void Move(Vector2 distance)
    {
        _offset += distance;
        while (_offset.X <  OffsetMin) ShiftOffset(Directions.Right);
        while (_offset.Y <  OffsetMin) ShiftOffset(Directions.Down);
        while (_offset.X >= OffsetMax) ShiftOffset(Directions.Left);
        while (_offset.Y >= OffsetMax) ShiftOffset(Directions.Up);
    }
    public void LinkWith(BoardData board)
    {
        if (board.Structures.Any(s => s.OwningBody == this)) _board = board;
    }
    public void Unlink()
    {
        if (_board.Structures.All(s => s.OwningBody != this)) _board = null;
    }

    private ObservableCollection<Vector2> _positions { get; }
    private Vector2 _offset = Vector2.Zero;
    private BoardData _board = null;
    private void ShiftOffset(Directions shiftDirection)
    {
        Vector2 shiftVector = shiftDirection.DirectionsToVector2();
        _offset += shiftVector;
        foreach (Vector2 position in _positions)
        {
            Remove(position);
            Add(position - shiftVector);
        }
    }

    private static Vector2 Floor(Vector2 vector)
        => new((float)System.Math.Floor(vector.X), (float)System.Math.Floor(vector.Y));
    private const float OffsetMargin = 0.1f;
    private const float OffsetMin = 0.0f - OffsetMargin;
    private const float OffsetMax = 1.0f + OffsetMargin;
}
