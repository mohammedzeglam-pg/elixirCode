defmodule Identicon do
  defstruct hex: nil, color: nil, grid: nil, pixel_map: nil

  def render(input) do
    input
    |> hash_input
    |> extract_color()
    |> build_grid()
    |> remove_odd_bytes()
    |> build_pixel_map()
    |> draw_identicon()
    |> save_identicon(input)
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon{hex: hex}
  end

  def extract_color(identicon = %Identicon{hex: [r, g, b | _]}) do
    %Identicon{identicon | color: {r, g, b}}
  end

  def build_grid(identicon) do
    grid =
      identicon.hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon{identicon | grid: grid}
  end

  def mirror_row([a, b, c]) do
    [a, b, c, b, a]
  end

  def remove_odd_bytes(identicon) do
    grid = identicon.grid |> Enum.filter(fn {code, _index} -> rem(code, 2) == 0 end)
    %Identicon{identicon | grid: grid}
  end

  def build_pixel_map(identicon = %Identicon{grid: grid}) do
    pixel_map = Enum.map(grid, &calculate_coordinates/1)

    %Identicon{identicon | pixel_map: pixel_map}
  end

  def calculate_coordinates({_, idx}) do
    x = rem(idx, 5) * 50
    y = div(idx, 5) * 50
    top_left = {x, y}
    bottom_right = {x + 50, y + 50}
    {top_left, bottom_right}
  end

  def draw_identicon(%Identicon{color: color, pixel_map: pixel_map}) do
    identicon = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(identicon, start, stop, fill)
    end)

    :egd.render(identicon)
  end

  def save_identicon(identicon, filename) do
    File.write("#{filename}.png", identicon)
  end
end
