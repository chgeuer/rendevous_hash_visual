defmodule SvgAnimator do
  @moduledoc """
  Creates animated SVGs by cycling through individual SVG frames.
  Similar to an animated GIF but using SVG animation features.
  """

  @doc """
  Creates an animated SVG from a list of SVG binaries and frame durations.

  ## Parameters
  - `frames`: List of SVG source code binaries
  - `frame_duration`: Duration each frame should be shown (in seconds)
  - `options`: Keyword list of options
    - `:loop`: Whether to loop the animation (default: true)
    - `:width`: Override width of the output SVG
    - `:height`: Override height of the output SVG

  ## Example
      frames = [
        "<svg>...</svg>",
        "<svg>...</svg>",
        "<svg>...</svg>"
      ]

      animated_svg = SvgAnimator.create_animation(frames, 0.5)
      File.write("animation.svg", animated_svg)
  """
  def create_animation(frames, frame_duration, options \\ []) do
    loop = Keyword.get(options, :loop, true)
    width = Keyword.get(options, :width)
    height = Keyword.get(options, :height)

    # Extract dimensions from first frame if not provided
    {svg_width, svg_height} = extract_dimensions(List.first(frames), width, height)

    # Calculate total animation duration
    total_duration = length(frames) * frame_duration

    # Generate animation groups
    animated_groups =
      frames
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {frame_svg, index} ->
        create_animated_group(frame_svg, index, frame_duration, total_duration)
      end)

    # Build the final animated SVG
    _animation_attributes = if loop, do: "repeatCount=\"indefinite\"", else: "repeatCount=\"1\""

    """
    <svg xmlns="http://www.w3.org/2000/svg"
         width="#{svg_width}" height="#{svg_height}"
         viewBox="0 0 #{svg_width} #{svg_height}">
      <defs>
        <style>
          .frame { opacity: 0; }
        </style>
      </defs>
      #{animated_groups}
    </svg>
    """
  end

  @doc """
  Creates an animated SVG with different durations for each frame.

  ## Parameters
  - `frames_with_durations`: List of tuples {svg_binary, duration_in_seconds}
  - `options`: Same options as create_animation/3

  ## Example
      frames = [
        {"<svg>...</svg>", 1.0},
        {"<svg>...</svg>", 0.5},
        {"<svg>...</svg>", 2.0}
      ]

      animated_svg = SvgAnimator.create_variable_animation(frames)
  """
  def create_variable_animation(frames_with_durations, options \\ []) do
    loop = Keyword.get(options, :loop, true)
    width = Keyword.get(options, :width)
    height = Keyword.get(options, :height)

    # Extract first frame for dimensions
    {first_frame, _} = List.first(frames_with_durations)
    {svg_width, svg_height} = extract_dimensions(first_frame, width, height)

    # Calculate total duration and cumulative times
    total_duration =
      frames_with_durations
      |> Enum.map(fn {_, duration} -> duration end)
      |> Enum.sum()

    # Generate animation groups with variable timing
    animated_groups =
      frames_with_durations
      |> Enum.scan(0, fn {_, duration}, acc -> acc + duration end)
      |> Enum.zip(frames_with_durations)
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {{end_time, {frame_svg, duration}}, index} ->
        start_time = end_time - duration
        create_variable_animated_group(frame_svg, index, start_time, end_time, total_duration)
      end)

    # Build the final animated SVG
    _animation_attributes = if loop, do: "repeatCount=\"indefinite\"", else: "repeatCount=\"1\""

    """
    <svg xmlns="http://www.w3.org/2000/svg" width="#{svg_width}" height="#{svg_height}" viewBox="0 0 #{svg_width} #{svg_height}">
      <defs>
        <style>
          .frame { opacity: 0; }
        </style>
      </defs>
    #{animated_groups}
    </svg>
    """
  end

  # Private functions

  defp extract_dimensions(svg_binary, override_width, override_height) do
    width = override_width || extract_attribute(svg_binary, "width") || "100"
    height = override_height || extract_attribute(svg_binary, "height") || "100"
    {width, height}
  end

  defp extract_attribute(svg_binary, attribute) do
    case Regex.run(~r/#{attribute}="([^"]+)"/, svg_binary) do
      [_, value] -> value
      _ -> nil
    end
  end

  defp create_animated_group(frame_svg, index, frame_duration, total_duration) do
    # Calculate animation timing as percentages
    start_percent = (index * frame_duration / total_duration * 100) |> Float.round(2)
    end_percent = ((index + 1) * frame_duration / total_duration * 100) |> Float.round(2)

    # Extract the inner content of the SVG (everything between <svg> tags)
    inner_content = extract_svg_content(frame_svg)

    """
      <g class="frame">
        <animate
          attributeName="opacity"
          values="0;1;1;0"
          keyTimes="0;#{start_percent / 100};#{end_percent / 100};1"
          dur="#{total_duration}s"
          repeatCount="indefinite" />
    #{inner_content}
      </g>
    """
  end

  defp create_variable_animated_group(frame_svg, _index, start_time, end_time, total_duration) do
    # Calculate animation timing as percentages
    start_percent = (start_time / total_duration * 100) |> Float.round(2)
    end_percent = (end_time / total_duration * 100) |> Float.round(2)

    # Extract the inner content of the SVG
    inner_content = extract_svg_content(frame_svg)

    """
      <g class="frame">
        <animate
          attributeName="opacity"
          values="0;1;1;0"
          keyTimes="0;#{start_percent / 100};#{end_percent / 100};1"
          dur="#{total_duration}s"
          repeatCount="indefinite" />
    #{inner_content}
      </g>
    """
  end

  defp extract_svg_content(svg_binary) do
    # Remove the outer <svg> tag and extract inner content
    svg_binary
    |> String.replace(~r/<svg[^>]*>/, "")
    |> String.replace(~r/<\/svg>$/, "")
    |> String.trim()
  end
end
