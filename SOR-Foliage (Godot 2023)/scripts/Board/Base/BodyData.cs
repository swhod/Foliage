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
    public IList<Vector2> Positions => _positions;
    /// <summary>
    /// Represents the offset from aligned with tile grid.
    /// </summary>
    public Vector2 Offset => _offset;
    /// <summary>
    /// Represents the board linked with this BodyData.
    /// </summary>
    public BoardData Board => _board;
    /// <summary>
    /// Moves this BodyData by given vector.
    /// </summary>
    /// <param name="vector">The vector to move by.</param>
    public void Move(Vector2 vector)
    {
        _offset += vector;
        while (_offset.X <  OffsetMin) ShiftOffsetBy(Directions.Right);
        while (_offset.Y <  OffsetMin) ShiftOffsetBy(Directions.Down);
        while (_offset.X >= OffsetMax) ShiftOffsetBy(Directions.Left);
        while (_offset.Y >= OffsetMax) ShiftOffsetBy(Directions.Up);
    }

    public event NotifyCollectionChangedEventHandler PositionsChanged
    {
        add => _positions.CollectionChanged += value;
        remove => _positions.CollectionChanged -= value;
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
    private void ShiftOffsetBy(Directions direction)
    {
        Vector2 vector = direction.DirectionsToVector2();
        _offset += vector;
        foreach (Vector2 position in _positions)
        {
            _positions.Remove(position);
            _positions.Add(position - vector);
        }
    }

    private const float OffsetMargin = 0.1f;
    private const float OffsetMin = 0.0f - OffsetMargin;
    private const float OffsetMax = 1.0f + OffsetMargin;
}
