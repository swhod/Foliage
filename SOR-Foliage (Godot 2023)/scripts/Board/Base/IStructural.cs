namespace Foliage.Board.Base;

public interface IStructural
{
    BodyData OwningBody { get; }
    BoardData BelongingBoard { get; }
}
