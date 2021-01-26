<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;

class App
{
    #[Route('/app', name: 'test')]
    public function test(Request $request)
    {
        foreach ($this->testYield() as $e) {
            echo $e;
        }
    }

    private function testYield()
    {
        $t = [1, 2, 3, 4, 5];
        foreach ($t as $e) {
            yield $e;
        }
    }
}