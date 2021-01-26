<?php

namespace App\Command;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class IndexCommand extends Command
{
    protected static $defaultName = 'app:index';

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $output->writeln("IndexCommand has been execute");

        return Command::SUCCESS;
    }
}