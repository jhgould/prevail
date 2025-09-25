require 'pry'
require 'set'

photo = [
  [0,1,1,0,0,0,0,0],
  [1,0,0,0,0,1,1,1],
  [1,0,0,0,0,0,0,1],
  [1,0,0,0,0,1,1,1]
]  

target_rows = 3
target_cols = 4


# photo = [
#   [1,1,1,1,  0,0,0,0],
#   [0,0,0,0,  1,1,1,1],
#   [0,0,0,0,  0,0,0,0],
#   [1,1,1,1,  0,0,0,0]
# ]

# target_rows = 3
# target_cols = 4

# photo = [
#   [1,1,1, 0,0,0],
#   [0,0,0, 1,1,1],
#   [1,1,1, 0,0,0],
#   [1,1,1, 0,0,0]
# ]

# target_rows = 4
# target_cols = 3


# photo = [
#   [1,1, 0,0,  1,1, 0,0],
#   [0,0, 1,1,  0,0, 1,1]
# ]
# 
# target_rows = 2
# target_cols = 4


def search(coords, photo, visited, current_piece)
  puts "search called"
  x, y = coords  
  rows = photo.length  
  cols = photo[0].length

  return unless x.between?(0, rows - 1)  
  return unless y.between?(0, cols - 1)  
  return if visited.include?([x, y])  
  return unless photo[x][y] == 1

  visited.add([x, y]) 
  current_piece << [x, y]

  nx = x - 1
  ny = y
  if nx >= 0 && photo[nx][ny] == 1 && !visited.include?([nx, ny])
    search([nx, ny], photo, visited, current_piece)
  end

  nx = x + 1
  ny = y
  if nx < rows && photo[nx][ny] == 1 && !visited.include?([nx, ny])
    search([nx, ny], photo, visited, current_piece)
  end

  nx = x
  ny = y - 1
  if ny >= 0 && photo[nx][ny] == 1 && !visited.include?([nx, ny])
    search([nx, ny], photo, visited, current_piece)
  end

  nx = x
  ny = y + 1
  if ny < cols && photo[nx][ny] == 1 && !visited.include?([nx, ny])
    search([nx, ny], photo, visited, current_piece)
  end
end


def normalize(coords)
  puts "normalize called"
  min_r = coords.map { |rc| rc[0] }.min 
  min_c = coords.map { |rc| rc[1] }.min  
  coords.map { |r, c| [r - min_r, c - min_c] } 
end

def find_pieces(photo)
  puts "find_pieces called"
  visited = Set.new  
  pieces  = [] 

  photo.length.times do |x|
    photo[x].length.times do |y|
      next unless photo[x][y] == 1
      next if visited.include?([x, y])

      current_piece = []
      search([x, y], photo, visited, current_piece)
      pieces << normalize(current_piece)
    end
  end
  pieces 
end

pieces = find_pieces(photo)


def placements(ori, target_rows, target_cols)
  puts "placements called"
  
  h = ori.map { |r, _| r }.max + 1 
  w = ori.map { |_, c| c }.max + 1  

  results = []
  (0..(target_rows - h)).each do |off_r|  
    (0..(target_cols - w)).each do |off_c| 
      placed = ori.map { |r, c| [r + off_r, c + off_c] } 
      results << placed  
    end
  end
  results
end


def build_candidates(pieces, target_rows, target_cols)
  puts "build_candidates called"
  pieces.map do |p|
    placements(p, target_rows, target_cols)
  end
end

piece_candidates = build_candidates(pieces, target_rows, target_cols)


solution = Array.new(pieces.length)
used = Set.new  

order = (0...pieces.length).to_a


def draw_board(rows, cols, solution)
  puts "draw_board called"
  board = Array.new(rows) { Array.new(cols, 0) }  
  solution.each_with_index do |cells, count|
    next unless cells
    label = count + 1
    cells.each { |r, c| board[r][c] = label }  
  end
  board
end

def solve(step, order, piece_candidates, used, solution)
  puts "solve called"
  return true if step >= order.length

  piece_index = order[step]

  piece_candidates[piece_index].each do |placement|
    next if placement.any? { |cell| used.include?(cell) }

    solution[piece_index] = placement
    placement.each { |cell| used.add(cell) }

    return true if solve(step + 1, order, piece_candidates, used, solution)

    placement.each { |cell| used.delete(cell) }
    solution[piece_index] = nil
  end

  false
end

if solve(0, order, piece_candidates, used, solution)
  board = draw_board(target_rows, target_cols, solution)
  board.each { |row| puts row.join(' ') }
end