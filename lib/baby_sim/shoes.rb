module BabySim
  module Shoes
    ::Shoes.app :width => 730, :height => 730, :title => 'Baby' do
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
          message = "Baby is #{@field.baby.status} (health meter #{@field.baby.health})\n"
          message += @field.baby.last_encounter_message unless @field.baby.last_encounter_message.nil?

          @status.replace message

          if @field.baby.finished?
            a.stop
            alert "Game over! Baby is #{@field.baby.status}."
          end
        end
      end

      new_simulation
    end

  end
end



