// See https://aka.ms/new-console-template for more information

using System;
using System.Threading;
using Adaptive.Aeron;
using Adaptive.Aeron.LogBuffer;
using Adaptive.Agrona;

const string channel = "aeron:ipc?term-length=128k";
const int streamId = 0x633c20;

var handler = HandlerHelper.ToFragmentHandler(PrintMessage);

try {
    using var aeron = Aeron.Connect();
    using var subscriber = aeron.AddSubscription(channel, streamId);

    while (subscriber.Poll(handler, 1) == 0) {
        Thread.Sleep(10);
    }
}
catch (Exception e) {
    Console.WriteLine(e);
}
finally {
    Console.WriteLine("Press any key to continue");
    Console.ReadKey();
}
return;

void PrintMessage(IDirectBuffer buffer, int offset, int length, Header header)
{
    var message = buffer.GetStringWithoutLengthUtf8(offset, length);
    Console.WriteLine($"Received message ({message}) to stream {header.StreamId:D} from session {header.SessionId:x} term id {header.TermId:x} term offset {header.TermOffset:D} ({length:D}@{offset:D})");
}
