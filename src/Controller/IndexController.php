<?php

namespace App\Controller;

use App\Message\NotificationMessage;
use Protoc\Model\Message;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Messenger\Bridge\Amqp\Transport\AmqpStamp;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Annotation\Route;

class IndexController extends AbstractController
{
    #[Route('/index', name: 'index')]
    public function index(MessageBusInterface $bus)
    {
        $notificationMessage = new NotificationMessage('Coucou je suis super message !');
        $bus->dispatch($notificationMessage, [
            new AmqpStamp('high', \AMQP_NOPARAM, [
                "headers" => [
                    "source" => "titi",
                ],
            ]),
        ]);

        $bus->dispatch($notificationMessage, [
            new AmqpStamp('high', \AMQP_NOPARAM, [
                "headers" => [
                    "source" => "toto",
                ],
            ]),
        ]);

        return new Response($notificationMessage->getContent());
    }

    #[Route('/index2', name: 'index2')]
    public function index2(MessageBusInterface $bus)
    {
        $message = (new Message())
            ->setId(123456)
            ->setActivity('board')
            ->setUser('eric')
        ;

        dump($message->serializeToString());

        return new Response();
    }
}