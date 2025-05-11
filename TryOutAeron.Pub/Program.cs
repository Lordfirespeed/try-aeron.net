using System;
using Adaptive.Aeron;
using Adaptive.Agrona.Concurrent;

const string channel = "aeron:ipc?term-length=128k";  // https://aeron.io/docs/cookbook-content/aeron-term-length-msg-size/
const int streamId = 0x633c20;  // openssl rand -hex 3

using var buffer = new UnsafeBuffer(new byte[16384]);
using var aeron = Aeron.Connect();
using var publisher = aeron.AddPublication(channel, streamId);

var message = buffer.PutStringWithoutLengthUtf8(
    0,
    """
    7UqkwAKQ5Lv+tZ1yAmy7q0d+OXJpsydeCdml5xsL8Erwb4ApxAoWpHMbOnnjKu+2
    E1piLCvDWJxZTrviVLtYll0rxMSUnEGprRnRvcSoLvWQlufUmx4yuzv8qlPdXrZh
    9UTm9L97WBO7xuM+ddEfhL9riAatbqMWea7BgyjTWkkeSPHRx7qUnCAakCWS3kPx
    r1PHp9i6TQpft8hID/xPfQ3fGas1NkuwFuNTyZ8fGqgaTdY+RdnnH7WrSfMNyDjO
    LEwpeH4glChyRhm61bYtsT0Kthol5iS96eZKJ8EOnXUqMpTdY17sdNKyfKXsSWLI
    2mgpu4F5+k7fmWJiPtsh1g==
    """
);
publisher.Offer(buffer, 0, message);
Console.WriteLine("Sent message");
