using System.Threading.Tasks;

namespace TryOutAeron.Sub.Concurrent;

public interface IIdleStrategy
{
    ValueTask Idle(int workCount);

    ValueTask Idle();

    void Reset();
}

public sealed class DelayIdleStrategy(int delayPeriodMilliseconds) : IIdleStrategy
{
    public async ValueTask Idle(int workCount)
    {
        if (workCount > 0) return;
        await Task.Delay(delayPeriodMilliseconds);
    }

    public async ValueTask Idle() => await Task.Delay(delayPeriodMilliseconds);

    public void Reset() { }
}
