class KbdComponent < ApplicationComponent
  BASE_CLASSES = "font-mono text-[10px] font-bold text-zinc-600 bg-zinc-100 border border-zinc-300 px-1.5 py-0.5 rounded-[1px] uppercase tracking-wide select-none"

  SIZES = {
    sm: "text-[10px] px-1.5 py-0.5",
    md: "text-[11px] px-2 py-0.5",
    lg: "text-xs px-2.5 py-1"
  }.freeze

  def initialize(key:, size: :md, class: nil)
    @key = key
    @size = size
    @custom_class = binding.local_variable_get(:class)
  end

  def computed_classes
    class_names(BASE_CLASSES, SIZES[@size], @custom_class)
  end
end
