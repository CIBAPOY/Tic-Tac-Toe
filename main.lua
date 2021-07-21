game = {}
self = {}

pieces = {'<font color="rgb(0,255,0)">X</font>','<font color="rgb(255,0,0)">O</font>'}

function game.new()
	self = {}

	return setmetatable(self, {__index = game})
end

function genBoard()
	board = {}

	for y = 1, 3 do
		board[y] = {}
		for x = 1, 3 do
			board[y][x] = 0
		end
	end

	return board
end

function game:display()
	cursor = 0
	for y = 1, 3 do
		for x = 1, 3 do
			cursor = cursor + 1
			spot = tostring('')

			if self.Board[y][x] > 0 then spot = pieces[self.Board[y][x]] end
			script.Parent:FindFirstChild(cursor).Text = spot
		end
	end
end
function game:create()


	self.Board = genBoard()
	self.Score = {0,0}

	self:display()
end

function game:findWin(bd)
	Winners = {
		{},
		{}
	}
	Board = bd or self.Board
	for x = 1, 3 do -- Vertical
		LastPiece = 0
		InRow = 0
		for y = 1, 3 do
			piece = Board[y][x]
			if piece > 0 then

				if LastPiece == piece or LastPiece == 0 then InRow = InRow + 1 end
				if InRow == 3 then
					Winners[piece][#Winners[piece] + 1] = {x,y}
				end
				LastPiece = piece
			end
		end
	end

	for y = 1, 3 do -- Horizontal
		LastPiece = 0
		InRow = 0
		for x = 1, 3 do
			piece = Board[y][x]
			if piece > 0 then

				if LastPiece == piece or LastPiece == 0 then InRow = InRow + 1 end
				if InRow == 3 then
					Winners[piece][#Winners[piece] + 1] = {x,y}
				end
				LastPiece = piece
			end
		end
	end

	InRow = 0
	LastPiece = 0
	for x = 1, 3 do
		piece = Board[x][x]

		if piece > 0 then

			if LastPiece == piece or LastPiece == 0 then InRow = InRow + 1 end
			if InRow == 3 then
				Winners[piece][#Winners[piece] + 1] = {x,x}
			end
			LastPiece = piece
		end
	end

	InRow = 0
	LastPiece = 0
	for x = 1, 3 do
		piece = Board[4-x][x]

		if piece > 0 then

			if LastPiece == piece or LastPiece == 0 then InRow = InRow + 1 end
			if InRow == 3 then
				Winners[piece][#Winners[piece] + 1] = {x,4-x}
			end
			LastPiece = piece
		end
	end


	if #Winners[1] == 0 and #Winners[2] == 0 then Winners = nil end
	return Winners
end	

function boardCopy(orig)
	copy = {}

	for k, v in pairs(orig) do
		copy[k] = {}
		for _, b in pairs(v) do
			copy[k][#copy[k] + 1] = b
		end
	end

	return copy
end

function game:AISet()
	dupeBoard = boardCopy(self.Board)

	PossibleWin = {}

	for x = 1, 3 do
		dupeBoard = boardCopy(self.Board)
		for y = 1, 3 do
			for i = 1, 2 do 
				if dupeBoard[y][x] == 0 then dupeBoard[y][x] = i end

				win = self:findWin(dupeBoard)
				if win and #win[i] > 0 and self.Board[y][x] == 0  then
					PossibleWin[i] = {y,x}
				end

				dupeBoard[y][x] = 0
				if dupeBoard[x][y] == 0 then dupeBoard[x][y] = i end

				win = self:findWin(dupeBoard) 			
				if win and #win[i] > 0 and self.Board[x][y] == 0  then
					PossibleWin[i] = {x,y}
				end

				dupeBoard[x][y] = 0

				if dupeBoard[x][x] == 0 then dupeBoard[x][x] = i end

				win = self:findWin(dupeBoard) 			
				if win and #win[i] > 0 and self.Board[x][x] == 0  then
					PossibleWin[i] = {x,x}
				end

				dupeBoard[x][x] = 0

				if dupeBoard[4-x][x] == 0 then dupeBoard[4-x][x] = i end
				win = self:findWin(dupeBoard)
				if win and #win[i] > 0 and self.Board[4-x][x] == 0  then
					PossibleWin[i] = {4-x,x}
				end

				dupeBoard[4-x][x] = 0
			end

		end

	end

	if PossibleWin[2] and self.Board[PossibleWin[2][1]][PossibleWin[2][2]] == 0 then self.Board[PossibleWin[2][1]][PossibleWin[2][2]] = 2 return end

	if PossibleWin[1] and self.Board[PossibleWin[1][1]][PossibleWin[1][2]] == 0 then self.Board[PossibleWin[1][1]][PossibleWin[1][2]] = 2 else
		repeat
			PossibleWin = {math.random(1,3), math.random(1,3)}
		until self.Board[PossibleWin[1]][PossibleWin[2]] == 0
		self.Board[PossibleWin[1]][PossibleWin[2]] = 2
	end
end

function game:isTie()
	amount = 1
	for y = 1, 3 do
		for x = 1, 3 do
			if self.Board[y][x] > 0 then amount = amount + 1 end
		end
	end

	if amount == 9 and not self:findWin() then self:display() return true end
	return false
end

function game:set(spot)
	if not spot then return false end
	spot = math.clamp(spot,1,9)
	-- Find X Y pos
	local CurrentSpot = 0
	local X,Y = 0,0
	for y = 1, 3 do
		for x = 1, 3 do
			CurrentSpot = CurrentSpot + 1
			if CurrentSpot == spot then X = x; Y = y end

		end
	end	

	if self.Board[Y] and self.Board[Y][X] == 0 then
		self.Board[Y][X] = 1
	else
		return false
	end

	self:display()
	if self:findWin() then return 'You won!' end

	wait(math.random(25,100)/100)
	self:AISet()

	self:display()

	if self:findWin() then return "You lost!" end

	if self:isTie() then self:display()  return "Tie!" end

end

return game
