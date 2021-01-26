<?php

return function (array $event) {
    return 'Hello ' . ($event['name'] ?? 'world');
};