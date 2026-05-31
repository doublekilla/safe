<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$req = Illuminate\Http\Request::create('/api/chat', 'GET');
$req->setUserResolver(function() { return App\Models\User::find(10); });
$res = app(App\Http\Controllers\Api\SpaceLink\ChatController::class)->index($req);
echo $res->getContent();
