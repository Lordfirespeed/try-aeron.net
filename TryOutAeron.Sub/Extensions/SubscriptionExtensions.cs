using System.Threading;
using System.Threading.Tasks;
using Adaptive.Aeron;
using Adaptive.Aeron.LogBuffer;
using TryOutAeron.Sub.Concurrent;

namespace TryOutAeron.Sub.Extensions;

public static class SubscriptionExtensions
{
    public static ValueTask PollLoopAsync(
        this Subscription subscription,
        FragmentHandler fragmentHandler,
        int fragmentLimit,
        IIdleStrategy idleStrategy,
        CancellationToken cancellationToken = default
    )
    {
        return PollLoopAsync(
            subscription,
            HandlerHelper.ToFragmentHandler(fragmentHandler),
            fragmentLimit,
            idleStrategy,
            cancellationToken
        );
    }

    public static async ValueTask PollLoopAsync(
        this Subscription subscription,
        IFragmentHandler fragmentHandler,
        int fragmentLimit,
        IIdleStrategy idleStrategy,
        CancellationToken cancellationToken = default
    ) {
        while (true) {
            if (cancellationToken.IsCancellationRequested) return;
            var workCount = subscription.Poll(fragmentHandler, fragmentLimit);
            await idleStrategy.Idle(workCount);
        }
    }
}
