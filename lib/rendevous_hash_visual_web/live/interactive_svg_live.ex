# lib/your_app_web/live/interactive_svg_live.ex
defmodule RendevousHashVisualWeb.InteractiveSvgLive do
  use RendevousHashVisualWeb, :live_view
  alias RendevousHashVisual.InteractiveState, as: State

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_from_state(
        State.new(
          regions_input: "Texas, Tennessee, Utah, Florida",
          zones_input: "Zone A, Zone B",
          vm_count_input: "8",
          max_vm_count: 32,
          respect_topology_constraints: true,
          text_input: "Patient Zero",
          replication_factor_input: "4",
          animated: true
        )
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("text_input_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :text_input, value)

  @impl Phoenix.LiveView
  def handle_event("regions_input_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :regions_input, value)

  @impl Phoenix.LiveView
  def handle_event("zones_input_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :zones_input, value)

  @impl Phoenix.LiveView
  def handle_event("topology_constraints_changed", params, socket) do
    value = Map.has_key?(params, "respect_topology_constraints")
    update_state_field(socket, :respect_topology_constraints, value)
  end

  @impl Phoenix.LiveView
  def handle_event("animated_changed", params, socket) do
    value = Map.has_key?(params, "animated_changed")
    update_state_field(socket, :animated, value)
  end

  @impl Phoenix.LiveView
  def handle_event("vm_count_slider_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :vm_count_input, value)

  @impl Phoenix.LiveView
  def handle_event("vm_count_text_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :vm_count_input, value)

  @impl Phoenix.LiveView
  def handle_event("scale_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :replication_factor_input, value)

  @impl Phoenix.LiveView
  def handle_event("replication_factor_text_changed", %{"value" => value}, socket),
    do: update_state_field(socket, :replication_factor_input, value)

  # Helper function to update state field and refresh socket
  defp update_state_field(socket, field, value) do
    state =
      socket.assigns.state
      |> State.merge(field, value)

    socket =
      socket
      |> assign_from_state(state)

    {:noreply, socket}
  end

  # Helper function to elevate all state fields to socket assigns
  defp assign_from_state(socket, state) do
    socket =
      socket
      |> assign(:state, state)

    state
    |> Map.from_struct()
    |> Enum.reduce(socket, fn {key, value}, acc ->
      assign(acc, key, value)
    end)
  end

  @impl Phoenix.LiveView
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 p-6">
      <!-- Header -->
      <div class="max-w-7xl mx-auto mb-6">
        <h1 class="text-3xl font-bold text-gray-800">
          Interactive Visualizer for Rendevous Hashing
        </h1>
      </div>
      
    <!-- Main Content Grid -->
      <div class="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-3 gap-6">
        
    <!-- Left Panel - Controls -->
        <div class="lg:col-span-1 space-y-6">
          
    <!-- Input Controls Card -->
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-lg font-semibold mb-4 text-gray-800">Configuration</h2>
            
    <!-- Text Input Section -->
            <div class="mb-6">
              <label for="text_input" class="block text-sm font-medium text-gray-700 mb-2">
                Actor ID
              </label>
              <form phx-change="text_input_changed">
                <input
                  type="text"
                  id="text_input"
                  name="value"
                  value={@text_input}
                  phx-debounce="30"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-gray-900"
                  placeholder="Enter text to generate nodes..."
                />
              </form>
            </div>
            
    <!-- Regions Input Section -->
            <div class="mb-6">
              <label for="regions_input" class="block text-sm font-medium text-gray-700 mb-2">
                Regions (comma-separated):
              </label>
              <form phx-change="regions_input_changed">
                <input
                  type="text"
                  id="regions_input"
                  name="value"
                  value={@regions_input}
                  phx-debounce="30"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-gray-900"
                  placeholder="Florida, Tennessee, Texas, Utah..."
                />
              </form>
            </div>
            
    <!-- Zone Input Section -->
            <div class="mb-6">
              <label for="zones_input" class="block text-sm font-medium text-gray-700 mb-2">
                Zones (comma-separated):
              </label>
              <form phx-change="zones_input_changed">
                <input
                  type="text"
                  id="zones_input"
                  name="value"
                  value={@zones_input}
                  phx-debounce="30"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-gray-900"
                  placeholder="Zone A, Zone B, Zone C..."
                />
              </form>
            </div>
            
    <!-- Topology Constraints Checkbox -->
            <div class="mb-6">
              <form phx-change="topology_constraints_changed">
                <div class="flex items-center">
                  <input
                    type="checkbox"
                    id="respect_topology_constraints"
                    name="respect_topology_constraints"
                    value="true"
                    checked={@respect_topology_constraints}
                    class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                  />
                  <label
                    for="respect_topology_constraints"
                    class="ml-2 block text-sm font-medium text-gray-700"
                  >
                    Respect Topology Constraints
                  </label>
                </div>
              </form>
              <p class="text-xs text-gray-500 mt-1">
                When enabled, node selection considers geographic distribution for optimal fault tolerance
              </p>
            </div>
            
    <!-- Topology Constraints Checkbox -->
            <div class="mb-6">
              <form phx-change="animated_changed">
                <div class="flex items-center">
                  <input
                    type="checkbox"
                    id="animated_changed"
                    name="animated_changed"
                    value="true"
                    checked={@animated}
                    class="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                  />
                  <label
                    for="animated_changed"
                    class="ml-2 block text-sm font-medium text-gray-700"
                  >
                    Animated
                  </label>
                </div>
              </form>
              <p class="text-xs text-gray-500 mt-1">
                When enabled, the SVG image is animated to show the selection process
              </p>
            </div>
            
    <!-- VM Count Slider -->
            <div class="mb-6">
              <div class="flex items-center justify-between mb-2">
                <label for="vm_count_slider" class="block text-sm font-medium text-gray-700">
                  Virtual Machines per AZ (max. {@max_vm_count})
                </label>
              </div>
              <div class="flex items-center gap-3">
                <div class="flex-1 relative">
                  <form phx-change="vm_count_slider_changed">
                    <input
                      type="range"
                      id="vm_count_slider"
                      name="value"
                      min="1"
                      max={@max_vm_count}
                      value={@vm_count}
                      class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
                    />
                  </form>
                  <div class="flex justify-between text-xs text-gray-500 mt-1">
                    <span>1</span> <span>{@max_vm_count}</span>
                  </div>
                </div>
                <form phx-change="vm_count_text_changed" class="flex-shrink-0">
                  <input
                    type="number"
                    id="vm_text"
                    name="value"
                    min="1"
                    max={@max_vm_count}
                    value={@vm_count}
                    phx-debounce="300"
                    class="w-16 px-2 py-1 border border-gray-300 rounded text-center text-sm text-gray-900 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500"
                  />
                </form>
              </div>
            </div>
            
    <!-- Replication Factor Slider -->
            <div class="mb-6">
              <div class="flex items-center justify-between mb-2">
                <label for="replication_slider" class="block text-sm font-medium text-gray-700">
                  Replication Factor (max. {@max_scale})
                </label>
              </div>
              <div class="flex items-center gap-3">
                <div class="flex-1 relative">
                  <form phx-change="scale_changed">
                    <input
                      type="range"
                      id="replication_slider"
                      name="value"
                      min="1"
                      max={@max_scale}
                      value={@replication_factor}
                      class="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer slider"
                    />
                  </form>
                  <div class="flex justify-between text-xs text-gray-500 mt-1">
                    <span>1</span> <span>{@max_scale}</span>
                  </div>
                </div>
                <form phx-change="replication_factor_text_changed" class="flex-shrink-0">
                  <input
                    type="number"
                    id="replication_text"
                    name="value"
                    min="1"
                    max={@max_scale}
                    value={@replication_factor}
                    phx-debounce="300"
                    class="w-16 px-2 py-1 border border-gray-300 rounded text-center text-sm text-gray-900 focus:outline-none focus:ring-1 focus:ring-indigo-500 focus:border-indigo-500"
                  />
                </form>
              </div>
            </div>
          </div>
          
    <!-- Stats Card -->
          <div class="bg-white rounded-lg shadow-lg p-6">
            <h2 class="text-lg font-semibold mb-4 text-gray-800">Current State</h2>
            <div class="space-y-3">
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Replicas</span>
                <span class="text-lg font-bold text-blue-600">{@replication_factor}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Total Nodes</span>
                <span class="text-lg font-bold text-green-600">{length(@nodes)}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Regions</span>
                <span class="text-lg font-bold text-orange-600">
                  {length(@regions)}
                </span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Zones</span>
                <span class="text-lg font-bold text-pink-600">{length(@zones)}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">VMs per AZ</span>
                <span class="text-lg font-bold text-indigo-600">{@vm_count}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-sm text-gray-600">Topology Constraints</span>
                <span class={"text-lg font-bold #{if @respect_topology_constraints, do: "text-green-600", else: "text-red-600"}"}>
                  {if @respect_topology_constraints, do: "ON", else: "OFF"}
                </span>
              </div>
            </div>
          </div>
        </div>
        
    <!-- Right Panel - Visualization -->
        <div class="lg:col-span-2">
          <div class="bg-white rounded-lg shadow-lg p-6 h-full">
            <h2 class="text-lg font-semibold mb-4 text-gray-800">Replication Visualization</h2>
            <div id="svg-container" class="flex justify-center items-start h-full min-h-[600px]">
              {Phoenix.HTML.raw(@svg_content)}
            </div>
          </div>
        </div>
      </div>
    </div>

    <style>
      .slider::-webkit-slider-thumb {
        appearance: none;
        height: 20px;
        width: 20px;
        background: #4f46e5;
        border-radius: 50%;
        cursor: pointer;
      }

      .slider::-moz-range-thumb {
        height: 20px;
        width: 20px;
        background: #4f46e5;
        border-radius: 50%;
        cursor: pointer;
        border: none;
      }
    </style>
    """
  end
end
