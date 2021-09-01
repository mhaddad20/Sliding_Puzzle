require 'ruby2d'

LIMIT=9
EACH_ROW=3
set width: 800
set height: 600
set background: 'yellow'

class Game
  def initialize
    $squares_array=[]
    $numbers_array=[]
    $numbers_row=[]
    $lines_coord_vertical=[]
    @push_to_squares=false
    @moves=0
    @inverse=false
    @finished=false
    $complete_array=[]
    $part_of_array=[]
    for a in 1..LIMIT
      $numbers_row.push(a)
      $part_of_array.push(a)
      if a%EACH_ROW==0
        $complete_array.push($part_of_array)
        $part_of_array=[]
      end
    end
    $complete_array[EACH_ROW-1][EACH_ROW-1]=0
    for a in 0..LIMIT-1
      if $numbers_row[a]==LIMIT
        $numbers_row[a]=0
      end
    end
    $numbers_row.shuffle!
    while countInverse(LIMIT)==false
      $numbers_row.shuffle!
      countInverse(LIMIT)
    end
    $coord_x_zero=[]
    $coord_y_zero=[]
    start_count=0
    for a in 1..LIMIT
      if a%EACH_ROW==0
        g= ($numbers_row[start_count..a-1]).to_a
        start_count+=EACH_ROW
        $numbers_array.push(g)
      end
    end
  end
  def countInverse(n) # to check if board is solvable
    count=0
    for a in 0..$numbers_row.size-1
      for b in a..$numbers_row.size-1
        if $numbers_row[b]<$numbers_row[a] && $numbers_row[b]!=0
          count+=1
        end
      end
    end
    if n%2==1
      return true if count%2==0
    else
      return true if (find_zero_1d_array+count)%2==1
    end
    false
  end
  def find_zero_1d_array
    row=0
    for a in 1..$numbers_row.size
      return row if $numbers_row[a-1]==0
      if a%EACH_ROW==0
        row+=1
      end
    end
    row
  end
  def draw_squares
    if $numbers_array==$complete_array # end the game if array is solved
      end_game
    end
    x=100
    y=100
    row=0
    col=0
    for a in 1..LIMIT
      arr=[]
      Square.new(x:x,y:y,color:'red',size:100)
      if @push_to_squares==false
        $squares_array.push([x,y])
      end
      if $numbers_array[row][col]!=0
        Text.new("#{$numbers_array[row][col]}",x:x+25,y:y+20,size:50)
      end
      col+=1
      arr.push(x,y)
      $lines_coord_vertical.push(arr)
      if a%EACH_ROW==0
        x=100
        Line.new(x1:x,y1:y,x2:x*(EACH_ROW+1),y2:y)
        y+=100
        row+=1
        col=0
      else
        x+=100
      end
    end
    @push_to_squares=true
  end

  def draw_vertical_line
    arr=$lines_coord_vertical
    for a in 0..EACH_ROW-1
      Line.new(x1:arr[a][0],y1:arr[0][1],x2:arr[LIMIT-EACH_ROW+a][0],y2:arr[LIMIT-EACH_ROW+a][1]+100)
    end
    Line.new(x1:arr[EACH_ROW-1][0]+100,y1:arr[EACH_ROW-1][1],x2:arr[LIMIT-1][0]+100,y2:arr[LIMIT-1][1]+100)
    Line.new(x1:arr[0][0],y1:arr[LIMIT-EACH_ROW][1]+100,x2:arr[LIMIT-1][0]+100,y2:arr[LIMIT-1][1]+100)
  end

  def find_zero
    $numbers_array.each_with_index do |x,y|
      for a in 0..EACH_ROW-1
        if x[a]==0
          $coord_x_zero=y
          $coord_y_zero=a
        end
      end
    end
  end

  def update_puzzle(x,y)
    if ((x-$coord_x_zero).abs==1 && (y-$coord_y_zero).abs==0)||
      ((x-$coord_x_zero).abs==0 && (y-$coord_y_zero).abs==1)
      $numbers_array[$coord_x_zero][$coord_y_zero]=$numbers_array[x][y]
      $numbers_array[x][y]=0
      @moves+=1
    end
  end
  def display_moves
    Text.new("Moves: #{@moves}",color:'black')
  end

  def check_coord_square(x,y)
    row=0
    col=0
    for a in 1..LIMIT
      shape = Square.new(x:$squares_array[a-1][0],y:$squares_array[a-1][1],color:'blue',size:100)
      if shape.contains?(x,y)
        update_puzzle(row,col)
      end
      if a%EACH_ROW==0
        row+=1
        col=0
      else
        col+=1
      end
    end
  end
  def finished?
    @finished
  end
  def end_game
    @finished=true
  end

end


game = Game.new

update do
  unless game.finished?
    clear
    game.draw_squares
    game.draw_vertical_line
    game.find_zero
    game.display_moves
  end
  if game.finished?
    Text.new("Game Over! Press 'R' to Restart",color:'red',x:100,y:50)
  end
end

on :key_down do |event|
  if game.finished? && event.key=='r'
    game=Game.new
  end
end

on :mouse_down do |event|
  unless game.finished?
    game.check_coord_square(event.x,event.y)
  end
end

show