using System.Collections.Generic;

namespace Foliage.BoardElement;

public interface IActable
{
    /// <summary>
    /// Maps the action names to actual action methods.
    /// </summary>
    Dictionary<string, BoardAction> Actions { get; set; }
}
