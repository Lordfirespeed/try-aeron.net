using System;
using System.Threading.Tasks;
using Adaptive.Aeron;
using Adaptive.Agrona;
using Adaptive.Agrona.Concurrent;

namespace TryOutAeron.Pub.Extensions;

public static class PublicationExtensions
{
    private static async ValueTask OfferAsync(Func<long> offerAction)
    {
        while (true) {
            var result = offerAction();
            if (result >= 0) return;
            switch (result) {
                case Publication.BACK_PRESSURED:
                    await Task.Delay(10);
                    continue;
                case Publication.NOT_CONNECTED:
                    return;
                case Publication.ADMIN_ACTION:
                    throw new InvalidOperationException("Offer failed due to an administrative action");
                case Publication.CLOSED:
                    throw new InvalidOperationException("Offer failed due to publication being closed");
                default:
                    throw new InvalidOperationException($"Offer failed with unrecognised failure result {result}");
            }
        }
    }

    public static ValueTask OfferAsync(
        this Publication publication,
        UnsafeBuffer buffer
    ) => OfferAsync(() => publication.Offer(buffer));

    public static ValueTask OfferAsync(
        this Publication publication,
        IDirectBuffer buffer,
        int offset,
        int length,
        ReservedValueSupplier? reservedValueSupplier = null
    ) => OfferAsync(() => publication.Offer(buffer, offset, length, reservedValueSupplier));

    public static ValueTask OfferAsync(
        this Publication publication,
        IDirectBuffer bufferOne,
        int offsetOne,
        int lengthOne,
        IDirectBuffer bufferTwo,
        int offsetTwo,
        int lengthTwo,
        ReservedValueSupplier? reservedValueSupplier = null
    ) => OfferAsync(() => publication.Offer(
        bufferOne,
        offsetOne,
        lengthOne,
        bufferTwo,
        offsetTwo,
        lengthTwo,
        reservedValueSupplier
    ));

    public static ValueTask OfferAsync(
        this Publication publication,
        DirectBufferVector[] vectors,
        ReservedValueSupplier? reservedValueSupplier = null
    ) => OfferAsync(() => publication.Offer(vectors, reservedValueSupplier));
}
