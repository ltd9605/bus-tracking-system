using BusTracking.Domain.Modules.Operations.Enums;
using BusTracking.Domain.Modules.Operations.Rules;
using Xunit;

namespace BusTracking.UnitTests.Operations;

public sealed class TripStateMachineTests
{
    [Theory]
    [InlineData(TripStatus.Planned, TripStatus.Ready)]
    [InlineData(TripStatus.Ready, TripStatus.InProgress)]
    [InlineData(TripStatus.InProgress, TripStatus.Completed)]
    public void AllowsSpecifiedTransitions(TripStatus from, TripStatus to)
    {
        Assert.True(TripStateMachine.IsAllowed(from, to));
    }

    [Fact]
    public void RejectsTransitionFromCompletedToInProgress()
    {
        Assert.False(TripStateMachine.IsAllowed(TripStatus.Completed, TripStatus.InProgress));
    }
}
