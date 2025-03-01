// src/Service/WebSocketServer.php
namespace App\Service;

use Ratchet\ConnectionInterface;
use Ratchet\MessageComponentInterface;

class WebSocketServer implements MessageComponentInterface
{
protected $clients = [];
protected $playerMoves = [];
protected $playerCount;

public function __construct(int $playerCount)
{
$this->playerCount = $playerCount;
}

public function onOpen(ConnectionInterface $conn)
{
$this->clients[$conn->resourceId] = $conn;
}

public function onMessage(ConnectionInterface $from, $msg)
{
$this->playerMoves[$from->resourceId] = $msg;
$this->checkAllPlayersPlayed();
}

public function onClose(ConnectionInterface $conn)
{
unset($this->clients[$conn->resourceId]);
unset($this->playerMoves[$conn->resourceId]);
$this->checkAllPlayersPlayed();
}

public function onError(ConnectionInterface $conn, \Exception $e)
{
$conn->close();
}

protected function checkAllPlayersPlayed()
{
if (count($this->playerMoves) === $this->playerCount) {
$this->updateGameLogic();
$this->sendGameUpdates();
$this->playerMoves = [];
}
}

protected function updateGameLogic()
{
// Implémentez ici la logique pour mettre à jour l'état du jeu en fonction des mouvements des joueurs.
// Vous pouvez accéder à la liste des mouvements des joueurs via $this->playerMoves.
}

protected function sendGameUpdates()
{
$gameState = 'Nouvel état du jeu'; // Mettez ici l'état actuel du jeu pour envoyer aux joueurs.
foreach ($this->clients as $client) {
$client->send($gameState);
}
}
}
