// See https://aka.ms/new-console-template for more information

using System;
using Adaptive.Aeron;
using Adaptive.Agrona.Concurrent;

const string channel = "aeron:ipc";
const int streamId = 42;

var buffer = new UnsafeBuffer(new byte[256]);

using var aeron = Aeron.Connect();
using var publisher = aeron.AddPublication(channel, streamId);

var message = buffer.PutStringWithoutLengthUtf8(0, "Hello World!");
publisher.Offer(buffer, 0, message);
Console.WriteLine("Sent message");
