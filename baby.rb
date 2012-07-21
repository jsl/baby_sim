class Thing
  attr_reader :name, :color, :effect

  def initialize(name, color, effect)
    @name   = name
    @color  = color
    @effect = effect
  end
end

class Cell
  attr_accessor :contents

  def initialize(contents = nil)
    @contents = contents
  end
end

SWORD = Thing.new('Samurai Sword', "#FF0000", -2)
BANANA = Thing.new('Banana', "#FFFF00", 2)

class Baby
  attr_reader :health, :color, :name
  attr_accessor :location

  def initialize
    @health   = 0
    @color    = "#999"
    @name     = 'Baby'
    @location = [15, 15]
  end

  def encounter(thing)
    @health += thing.effect
  end

  def status
    if (health > 5)
      "thriving"

    elsif (health > 0) && (health < 4)
      "happy"

    elsif health == 0
      "ok"

    elsif (health > -5) && (health < 0)
      "crying"

    elsif health < -4
      "dead"

    end
  end

  def thriving?
    status == "thriving"
  end

  def dead?
    status == "dead"
  end

  def finished?
    dead? || thriving?
  end
end

class Field
  CELL_SIZE = 20
  UNITS_WIDE  = 25
  UNITS_TALL  = 25


  attr_reader :cell_size, :offset, :baby

  def initialize(app)
    @app    = app
    @field  = []
    @baby   = Baby.new


    UNITS_TALL.times { @field << Array.new(UNITS_WIDE) { Cell.new } }
    @width, @height = UNITS_WIDE * CELL_SIZE, UNITS_TALL * CELL_SIZE
    @offset = [(@app.width - @width.to_i) / 2, (@app.height - @height.to_i) / 2]
  end

  def paint
    0.upto UNITS_TALL-1 do |y|
      0.upto UNITS_WIDE-1 do |x|
        @app.nostroke
        render_cell(x, y)
      end
    end

    10.times {
      x, y = random_empty_cell
      add_to_cell(x, y, SWORD)
    }

    50.times {
      x, y = random_empty_cell
      add_to_cell(x, y, BANANA)
    }

    add_to_cell(@baby.location.first, @baby.location.last, @baby)
  end

  def render_cell(x, y, color = "#AAA", stroke = true)
    @app.stroke "#666" if stroke
    @app.fill color
    @app.rect x*CELL_SIZE, y*CELL_SIZE, CELL_SIZE-1, CELL_SIZE-1
    @app.stroke "#BBB" if stroke
    @app.line x*CELL_SIZE+1, y*CELL_SIZE+1, x*CELL_SIZE+CELL_SIZE-1, y*CELL_SIZE
    @app.line x*CELL_SIZE+1, y*CELL_SIZE+1, x*CELL_SIZE, y*CELL_SIZE+CELL_SIZE-1
  end

  def add_to_cell(x, y, thing)
    render_cell(x, y, thing.color, false)

    self[x, y] = Cell.new(thing)

    @app.nostroke
    @app.para thing.name[0], :left => x*CELL_SIZE + 3, :top => y*CELL_SIZE - 2, :font => '13px', :stroke => "#00A"
  end

  def clean_cell(x, y)
    render_cell(x, y)
    self[x, y] = Cell.new
  end

  def choose_adjacent_cell(x, y)
    move = Proc.new {|pos| pos += [-1, 0, 1].sample }
    new_x, new_y = [move.call(x), move.call(y)]
  end

  def move_baby
    clean_cell(@baby.location.first, @baby.location.last)

    @baby.location = random_direction(@baby.location.first, @baby.location.last)

    if contents = self[@baby.location.first, @baby.location.last].contents
      @baby.encounter(contents)
    end

    add_to_cell(@baby.location.first, @baby.location.last, @baby)
  end

  # Returns an available cell adjacent to the given x, y
  def random_direction(x, y)
    new_x = new_y = nil

    until [x, y] != [new_x, new_y] && cell_exists?(new_x, new_y)
      new_x, new_y = choose_adjacent_cell(x, y)
    end

    [new_x, new_y]
  end

  def random_empty_cell
    x = y = nil

    until cell_exists?(x, y) && self[x, y].contents.nil?
      x = (1..UNITS_WIDE).to_a.sample
      y = (1..UNITS_TALL).to_a.sample
    end

    [x, y]
  end

  def cell_exists?(x, y)
    ((0...UNITS_WIDE).include? x) && ((0...UNITS_TALL).include? y)
  end

  def [](*args)
    x, y = args
    raise "Cell #{x}:#{y} does not exists!" unless cell_exists?(x, y)
    @field[y][x]
  end

  def []=(*args)
    x, y, v = args
    cell_exists?(x, y) ? @field[y][x] = v : false
  end
end

Shoes.app :width => 730, :height => 730, :title => 'Baby' do
  def render_field
    clear do
      background rgb(50, 50, 90, 0.7)

      flow :margin => 4 do
        button("Start over") { new_simulation }
      end

      stack do @status = para :stroke => white end

      @field.paint

      para "Watch out baby!!!", :top => 510, :left => 0, :stroke => white,  :font => "11px"
    end
  end

  def new_simulation
    @field = Field.new(self)

    translate -@old_offset.first, -@old_offset.last unless @old_offset.nil?
    translate @field.offset.first, @field.offset.last
    @old_offset = @field.offset

    render_field

    a = animate(5) do
      @field.move_baby
      @status.replace "Baby is #{@field.baby.status} (health meter #{@field.baby.health})"

      a.stop if @field.baby.finished?
    end
  end

  new_simulation
end
