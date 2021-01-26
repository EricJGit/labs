<?php

namespace App\Controller;

use App\Message\NotificationMessage;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Messenger\MessageBusInterface;
use Symfony\Component\Routing\Annotation\Route;

class IndexController extends AbstractController
{
    #[Route('/index', name: 'index')]
    public function index(MessageBusInterface $bus)
    {
        $notificationMessage = new NotificationMessage('Coucou je suis super message !');
        $bus->dispatch($notificationMessage);

        return new Response($notificationMessage->getContent());
    }
}