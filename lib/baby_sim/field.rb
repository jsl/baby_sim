module BabySim
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

      Thing.all.each do |thing|
        thing.count.times do
          x, y = random_empty_cell
          add_to_cell(x, y, thing)
        end
      end

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
end
