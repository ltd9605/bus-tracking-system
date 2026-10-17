using BusTracking.Domain.Modules.Operations.Enums;

namespace BusTracking.Domain.Modules.Operations.Rules;

// State transitions from section 5.4 of the specification.
// Actor, assignment, version and timing guards must also be checked by
// the application use case before accepting the transition.
public static class TripStateMachine
{
    public static bool IsAllowed(TripStatus from, TripStatus to) => (from, to) switch
    {
        (TripStatus.Planned, TripStatus.Ready) => true,
        (TripStatus.Planned, TripStatus.Cancelled) => true,
        (TripStatus.Ready, TripStatus.InProgress) => true,
        (TripStatus.Ready, TripStatus.Cancelled) => true,
        (TripStatus.InProgress, TripStatus.Paused) => true,
        (TripStatus.Paused, TripStatus.InProgress) => true,
        (TripStatus.InProgress, TripStatus.Completed) => true,
        (TripStatus.InProgress, TripStatus.Aborted) => true,
        _ => false
    };
}
