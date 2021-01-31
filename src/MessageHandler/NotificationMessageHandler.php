<?php

namespace App\MessageHandler;

use App\Message\NotificationMessage;
use Psr\Log\LoggerInterface;
use Symfony\Component\Messenger\Handler\MessageHandlerInterface;

class NotificationMessageHandler implements MessageHandlerInterface
{
    public function __construct(
        private LoggerInterface $logger
    )
    {
    }

    public function __invoke(NotificationMessage $notificationMessage)
    {
        //$this->logger->info($notificationMessage->getContent());
    }
}