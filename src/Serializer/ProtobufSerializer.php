<?php

namespace App\Serializer;

use Google\Protobuf\Internal\Message;
use Psr\Log\LoggerInterface;
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\Transport\Serialization\SerializerInterface;

class ProtobufSerializer implements SerializerInterface
{
    public function __construct(
        private LoggerInterface $logger
    )
    {
    }

    public function decode(array $encodedEnvelope): Envelope
    {
        $message = new Message($encodedEnvelope["body"]);
        $stamps = [];

        return new Envelope($message, $stamps);
    }

    public function encode(Envelope $envelope): array
    {
        $message = $envelope->getMessage();

        $body = "";
        if ($message instanceof Message) {
            $body = $message->serializeToString();
        }

        return [
            "body" => $body,
        ];
    }
}
