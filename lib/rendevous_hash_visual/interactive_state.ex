defmodule RendevousHashVisual.InteractiveState do
  @moduledoc """
  This module represents the interactive state of the Rendevous Hash visualization.

  ## Field Dependencies

  The following MermaidJS flowchart illustrates how computed fields depend on input fields
  and other computed fields:

  ```mermaid
  flowchart TD
      %% Input fields (user-provided)
      TI[text_input]
      RI[regions_input]
      ZI[zones_input]
      VCI[vm_count_input]
      MVC[max_vm_count]
      RF[replication_factor]
      RTC[respect_topology_constraints]

      %% Computed fields
      R[regions]
      Z[zones]
      VC[vm_count]
      VMS[vms]
      BH[bucket_hashes]
      N[nodes]
      MS[max_scale]
      SVG[svg_content]

      %% Dependencies
      RI --> R
      ZI --> Z
      VCI --> VC
      VC --> VMS
      R --> BH
      Z --> BH
      VMS --> BH
      BH --> N
      TI --> N
      RTC --> N
      N --> MS
      N --> SVG
      RF --> SVG

      %% Styling
      classDef inputField fill:#e1f5fe,stroke:#0277bd,stroke-width:2px
      classDef computedField fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
      classDef finalOutput fill:#e8f5e8,stroke:#2e7d32,stroke-width:3px

      class TI,RI,ZI,VCI,MVC,RF,RTC inputField
      class R,Z,VC,VMS,BH,N,MS computedField
      class SVG finalOutput
  ```

  ### Field Types:
  - **Input fields** (blue): Direct user inputs or configuration
  - **Computed fields** (purple): Derived from other fields using `computed/3`
  - **Final output** (green): The SVG content rendered to the user

  ## Automatic Mermaid Diagram Generation

  This module automatically provides a `mermaid/0` function that generates the above flowchart:

      iex> RendevousHashVisual.InteractiveState.mermaid() |> String.contains?("flowchart TD")
      true

  """

  use ReactiveStruct

  alias RendevousHashTopology.ComputeNode
  alias RendevousHashTopology.Helpers.Drawing

  defstruct ~w(
    text_input
    regions_input regions
    zones_input zones
    vm_count_input vm_count max_vm_count vms
    replication_factor_input replication_factor
    bucket_hashes
    nodes
    max_scale
    respect_topology_constraints
    animated svg_content
    )a

  computed(:regions, deps: [:regions_input], do: regions_input |> split_csv())
  computed(:zones, deps: [:zones_input], do: zones_input |> split_csv())

  computed(:vm_count,
    deps: [:vm_count_input, :max_vm_count],
    do: parse_vm_count(vm_count_input, max_vm_count)
  )

  computed(:vms, deps: [:vm_count], do: Range.new(1, vm_count))

  computed(:bucket_hashes,
    deps: [:regions, :zones, :vms],
    do:
      for region <- regions,
          zone <- zones,
          vm <- vms do
        ComputeNode.new(region, zone, vm)
      end
      |> RendevousHash.pre_compute_list()
  )

  computed(:nodes,
    deps: [:bucket_hashes, :text_input, :respect_topology_constraints],
    do:
      if respect_topology_constraints do
        bucket_hashes
        |> RendevousHash.list(text_input)
        |> RendevousHashTopology.sort_by_optimum_storage_resiliency()
      else
        bucket_hashes
        |> RendevousHash.list(text_input)
      end
  )

  computed(:max_scale, deps: [:nodes], do: max(1, length(nodes) - 1))

  computed(:replication_factor,
    deps: [:replication_factor_input, :max_scale],
    do: parse_replication_factor(replication_factor_input, max_scale)
  )

  computed(:svg_content,
    deps: [:nodes, :replication_factor, :animated],
    do:
      if replication_factor > 1 and animated do
        generate_animated_svg(nodes, replication_factor)
      else
        generate_svg(nodes, replication_factor)
      end
  )

  # Private functions
  # Helper function to split CSV input and trim whitespace
  defp split_csv(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
  end

  # Parse and validate vm_count from string input
  defp parse_vm_count(vm_count, max_vm_count) when is_integer(vm_count) do
    cond do
      vm_count < 1 -> 1
      vm_count > max_vm_count -> max_vm_count
      true -> vm_count
    end
  end

  defp parse_vm_count(vm_count_input, max_vm_count) when is_binary(vm_count_input) do
    case Integer.parse(vm_count_input) do
      {vm_count, ""} when vm_count >= 1 and vm_count <= max_vm_count ->
        parse_vm_count(vm_count, max_vm_count)

      _ ->
        # Return default if invalid
        1
    end
  end

  defp parse_replication_factor(replication_factor_input, max_scale)
       when is_binary(replication_factor_input) do
    case Integer.parse(replication_factor_input) do
      {replication_factor, ""} when replication_factor >= 1 and replication_factor <= max_scale ->
        replication_factor

      _ ->
        # Return min of current value and max_scale if invalid
        min(1, max_scale)
    end
  end

  defp parse_replication_factor(replication_factor_input, max_scale)
       when is_integer(replication_factor_input) do
    min(replication_factor_input, max_scale)
  end

  defp parse_replication_factor(_replication_factor_input, max_scale), do: min(1, max_scale)

  defp trim_xml(xml) do
    xml
    |> String.replace(~r/\s+/, " ")
    |> String.replace(~r/>\s+</, "><")
    |> String.replace(~r/\s*=\s*/, "=")
    |> String.trim()
  end

  defp generate_animated_svg(nodes, max_replication_factor) when max_replication_factor > 1 do
    # Generate frames for animation from 1 to max_replication_factor
    for replication_factor <- 1..max_replication_factor do
      Drawing.generate_svg(nodes, replication_factor)
      |> trim_xml()
    end

    # Create animated SVG with 1 second per frame
    |> SvgAnimator.create_animation(1.0)
  end

  defp generate_animated_svg(nodes, replication_factor) do
    # Fallback for single frame (when max_replication_factor is 1)
    generate_svg(nodes, replication_factor)
  end

  defp generate_svg(nodes, number_of_nodes) do
    # Generate single static SVG frame
    Drawing.generate_svg(nodes, number_of_nodes)
    |> trim_xml()
  end
end
