UdpHandler = Class{}

function UdpHandler:init(socket, ip, port)
  self.socket = socket
  self.udp = self.socket.udp()
  -- dont wait for data to come into empty socket
  self.udp:settimeout(0)
  --self.udp:setsockname('*', 0)
  self.udp:setpeername(ip, port)
end

function UdpHandler:connectToServer()
  self.udp:send("connect")
end

function UdpHandler:sendToServer(msg)
  self.udp:send(msg)
end

function UdpHandler:requestUpdate()
  self.udp:send("update")
end

--updates server of given players position and this serves tor request an update too
function UdpHandler:updateServerAndRequestUpdate(player)
  self.udp:send("player" .. " " .. tostring(player.paddle.x)
      .. " " .. tostring(player.paddle.y))
end

function UdpHandler:receiveMessageFromServer()
  data = self.udp:receive()
  if data then
    cmd = data:match("(%S*)")
    return cmd
  end
  socket.sleep(0.01)
end

function UdpHandler:connectedToServer()
  cmd = self:receiveMessageFromServer()
  if cmd == "connectionSuccess" then
    return true
  else
    return false
  end
end

function UdpHandler:otherPlayerIsConnected()
  cmd = self:receiveMessageFromServer()
  if cmd == "allConnected" then
    return true
  else
    return false
  end
end

-- check if other player is ready, also returns the player number of this player
function UdpHandler:otherPlayerIsReady()
  cmd = self:receiveMessageFromServer()
  if cmd == "player1ready" then
    return 1
  elseif cmd == "player2ready" then
    return 2
  else
    return nil
  end

end

function UdpHandler:receivePositionUpdate()
  local data = self.udp:receive()
  if data then
    playerx, playery, ballx, bally = data:match("(%d*%.?%d*) (%d*%.?%d*) (%d*%.?%d*) (%d*%.?%d*)")
    return playerx, playery, ballx, bally
  else
    return nil
  end
end

--handles a score update from server and if not,
--updates player and ball in world depedning on what position update is received,
-- if player, then check what playerNumber is this palyer to update the correct player.
-- return true if position update received, return false if not
function UdpHandler:updateWorld(world, playerNumber)
  local data = self.udp:receive()
  if data then
    cmd, score = data:match("(%S*) (%d*%.?%d*)")
    if cmd == "score" then
      return tonumber(score)
    else
      playerx, playery, ballx, bally = data:match("(%-?%d*%.?%d*) (%-?%d*%.?%d*) (%-?%d*%.?%d*) (%-?%d*%.?%d*)")
      if playerx then
        if playerNumber == 1 then
          world.player2.paddle.x = tonumber(playerx)
          world.player2.paddle.y = tonumber(playery)
        else
          world.player1.paddle.x = tonumber(playerx)
          world.player1.paddle.y = tonumber(playery)
        end
        world.ball.x = tonumber(ballx)
        world.ball.y = tonumber(bally)
        return true
      else
        return false
      end
    end
  end
end

function UdpHandler:sendUpdateConfirmation()
  self:sendToServer("updated")
end

function UdpHandler:receiveServeMessage()
  message = self:receiveMessageFromServer()
  if message == "serve" then
    return 1
  elseif message == "waitForServe" then
    return 2
  else
    return nil
  end
end

function UdpHandler:sendServeMessage()
  self:sendToServer("serve")
end

function UdpHandler:receiveGameStart()
  local cmd = self:receiveMessageFromServer()
  if cmd == "gameStart" then
    return true
  else
    return false
  end
end

function UdpHandler:sendRestartMessage()
  self:sendToServer("restart")
end

function UdpHandler:receiveRestartConfirmation()
  message = self:receiveMessageFromServer()
  if message == "restart" then
    return true
  else
    return false
  end
end
