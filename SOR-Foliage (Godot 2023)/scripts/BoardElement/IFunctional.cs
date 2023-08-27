using System.Collections.Immutable;

namespace Foliage.BoardElement;

public interface IFunctional
{
    /// <summary>
    /// Represents the name of the functionality.
    /// </summary>
    public string Name { get; init; }

    /// <summary>
    /// Maps the identifiers to the actions.
    /// </summary>
    public ImmutableDictionary<string, Behaviour> Actions { get; init; }
}
